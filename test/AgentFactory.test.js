const { expect } = require('chai');
const { ethers, upgrades } = require('hardhat');

describe('AgentFactory', function () {
  let CircuitBreaker;
  let circuitBreaker;
  let AgentFactory;
  let agentFactory;
  let BEP007;
  let bep007;
  let BEP007Enhanced;
  let bep007Enhanced;
  let BEP007Governance;
  let bep007Governance;
  let MerkleTreeLearning;
  let merkleTreeLearning;
  let MockAgentLogic;
  let mockAgentLogic;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers
    CircuitBreaker = await ethers.getContractFactory('CircuitBreaker');
    BEP007Governance = await ethers.getContractFactory('BEP007GovernanceEnhanced');
    BEP007 = await ethers.getContractFactory('BEP007');
    BEP007Enhanced = await ethers.getContractFactory('BEP007EnhancedImpl');
    AgentFactory = await ethers.getContractFactory('AgentFactory');
    MerkleTreeLearning = await ethers.getContractFactory('MerkleTreeLearning');
    MockAgentLogic = await ethers.getContractFactory('MockAgentLogic');
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();


      // Deploy CircuitBreaker
    circuitBreaker = await upgrades.deployProxy(
      CircuitBreaker,
      [owner.address, owner.address],
      { initializer: "initialize"}
    );
    await circuitBreaker.deployed();

    // Deploy BEP007 with CircuitBreaker
    bep007 = await upgrades.deployProxy(
      BEP007,
      ["Governance NFA", "GNFA", circuitBreaker.address],
      { initializer: "initialize", kind: "uups" }
    );
    await bep007.deployed();


    // Deploy BEP007Governance (governance)
    bep007Governance = await upgrades.deployProxy(
      BEP007Governance,
      ["NFA Governance", bep007.address, owner.address, 7, 2, 2],
      { initializer: "initialize", kind: "uups"}
    );
    await bep007Governance.deployed();

    // Deploy BEP007Enhanced implementation
    bep007Enhanced = await upgrades.deployProxy(
      BEP007Enhanced,
      ["Enhanced Non-Fungible Agent", "ENFA", bep007Governance.address],
      { initializer: "initialize", kind: "uups" }
    );
    await bep007Enhanced.deployed();



    // Deploy MerkleTreeLearning module
    merkleTreeLearning = await upgrades.deployProxy(
      MerkleTreeLearning,
      [bep007Enhanced.address],
      { initializer: "initialize" }
    );
    await merkleTreeLearning.deployed();

    // Deploy MockAgentLogic
    mockAgentLogic = await MockAgentLogic.deploy(
      bep007Enhanced.address,
      "Mock Agent",
      "Mock Description",
      "Mock Experience",
      ["capability1", "capability2"],
      ["domain1.com", "domain2.com"]
    );
    await mockAgentLogic.deployed();

    // Deploy AgentFactory
    agentFactory = await upgrades.deployProxy(
      AgentFactory,
      [bep007Enhanced.address, bep007Governance.address, merkleTreeLearning.address],
      { initializer: "initialize", kind: "uups"  }
    );
    await agentFactory.deployed();


    // Approve the mock agent logic template through governance
    await bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("approveTemplate", [mockAgentLogic.address, "mock", "1.0.0"])
    );

    // Approve the learning module through governance
    await bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("approveLearningModule", [merkleTreeLearning.address, "merkle", "1.0.0"])
    );
  });

  describe('Deployment', function () {
    it('Should set the right implementation', async function () {
      expect(await agentFactory.implementation()).to.equal(bep007Enhanced.address);
    });

    it('Should set the right governance', async function () {
      expect(await agentFactory.governance()).to.equal(bep007Governance.address);
    });

    it('Should set the right default learning module', async function () {
      expect(await agentFactory.defaultLearningModule()).to.equal(merkleTreeLearning.address);
    });

    it('Should initialize learning configuration correctly', async function () {
      const config = await agentFactory.getLearningConfig();
      expect(config.learningEnabledByDefault).to.be.true;
      expect(config.minConfidenceThreshold).to.equal(ethers.utils.parseEther('0.5'));
      expect(config.maxLearningModulesPerAgent).to.equal(3);
      expect(config.learningAnalyticsUpdateInterval).to.equal(86400);
      expect(config.requireSignatureForLearning).to.be.false;
    });

    it('Should initialize global learning stats correctly', async function () {
      const stats = await agentFactory.getGlobalLearningStats();
      expect(stats.totalAgentsCreated).to.equal(0);
      expect(stats.totalLearningEnabledAgents).to.equal(0);
      expect(stats.totalLearningInteractions).to.equal(0);
      expect(stats.totalLearningModules).to.equal(1); // One approved module
      expect(stats.averageGlobalConfidence).to.equal(0);
    });
  });

  describe('Template Management', function () {
    it('Should approve a new template', async function () {
      const newMockLogic = await MockAgentLogic.deploy(
        bep007Enhanced.address,
        "New Mock Agent",
        "New Description",
        "New Experience",
        ["new_capability"],
        ["new_domain.com"]
      );
      await newMockLogic.deployed();

      await expect(bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("approveTemplate", [newMockLogic.address, "new_mock", "2.0.0"])
    )).to.emit(agentFactory, 'TemplateApproved')
        .withArgs(newMockLogic.address, "new_mock", "2.0.0");



      expect(await agentFactory.approvedTemplates(newMockLogic.address)).to.be.true;
      expect(await agentFactory.getLatestTemplate("new_mock")).to.equal(newMockLogic.address);
    });

    it('Should revoke a template', async function () {
      await bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("revokeTemplate", [mockAgentLogic.address]))


      expect(await agentFactory.approvedTemplates(mockAgentLogic.address)).to.be.false;
    });

    it('Should only allow governance to approve templates', async function () {
      const newMockLogic = await MockAgentLogic.deploy(
        bep007Enhanced.address,
        "Unauthorized Mock",
        "Description",
        "Experience",
        ["capability"],
        ["domain.com"]
      );
      await newMockLogic.deployed();

      await expect(
        agentFactory.connect(addr1).approveTemplate(newMockLogic.address, "unauthorized", "1.0.0")
      ).to.be.revertedWith("AgentFactory: caller is not governance");
    });

    it('Should reject zero address template', async function () {

      await expect(
        bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("approveTemplate", [ethers.constants.AddressZero, "zero", "1.0.0"]))
      ).to.be.revertedWith("AgentFactory: template is zero address");
    });
  });

  describe('Learning Module Management', function () {
    it('Should approve a new learning module', async function () {
      const newLearningModule = await upgrades.deployProxy(
        MerkleTreeLearning,
        [bep007Enhanced.address],
        { initializer: "initialize" }
      );
      await newLearningModule.deployed();

      await expect(bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("approveLearningModule", [newLearningModule.address, "new_merkle", "2.0.0"])))
        .to.emit(agentFactory, 'LearningModuleApproved')
        .withArgs(newLearningModule.address, "new_merkle", "2.0.0");

      expect(await agentFactory.approvedLearningModules(newLearningModule.address)).to.be.true;
      expect(await agentFactory.getLatestLearningModule("new_merkle")).to.equal(newLearningModule.address);
    });

    it('Should revoke a learning module', async function () {
      await bep007Governance.executeAction(
      agentFactory.address,
      agentFactory.interface.encodeFunctionData("revokeLearningModule", [merkleTreeLearning.address]));
      expect(await agentFactory.approvedLearningModules(merkleTreeLearning.address)).to.be.false;
    });

    it('Should only allow governance to approve learning modules', async function () {
      const newLearningModule = await upgrades.deployProxy(
        MerkleTreeLearning,
        [bep007Enhanced.address],
        { initializer: "initialize" }
      );
      await newLearningModule.deployed();

      await expect(
        agentFactory.approveLearningModule(newLearningModule.address, "unauthorized", "1.0.0")
      ).to.be.revertedWith("AgentFactory: caller is not governance");
    });

    it('Should check if learning module is approved', async function () {
      expect(await agentFactory.isLearningModuleApproved(merkleTreeLearning.address)).to.be.true;
      expect(await agentFactory.isLearningModuleApproved(addr1.address)).to.be.false;
    });
  });

  describe('Basic Agent Creation', function () {
    it('Should create an agent with basic parameters', async function () {


      const tx = await agentFactory.connect(addr1)["createAgent(string,string,address,string)"](
        "Test111 Agent",
        "TA",
        mockAgentLogic.address,
        "ipfs://QmTest"
      );

      const receipt = await tx.wait();
      const agentCreatedEvent = receipt.events.find(e => e.event === 'AgentCreated');
      expect(agentCreatedEvent.args.owner).to.equal(addr1.address);
      expect(agentCreatedEvent.args.logic).to.equal(mockAgentLogic.address);
      expect(agentCreatedEvent.args.learningEnabled).to.be.true; // Default enabled
      expect(agentCreatedEvent.args.learningModule).to.equal(merkleTreeLearning.address);

      // Verify global stats updated
      const stats = await agentFactory.getGlobalLearningStats();
      expect(stats.totalAgentsCreated).to.equal(1);
      expect(stats.totalLearningEnabledAgents).to.equal(1);
    });

    it('Should create an agent with extended metadata', async function () {
      const extendedMetadata = {
        persona: 'Test Persona',
        experience: 'Test Experience',
        voiceHash: 'Test Voice Hash',
        animationURI: 'ipfs://QmTestAnimation',
        vaultURI: 'ipfs://QmTestVault',
        vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
      };

      const tx = await agentFactory.connect(addr1)["createAgent(string,string,address,string,(string,string,string,string,string,bytes32))"](
        "Extended Agent",
        "EA",
        mockAgentLogic.address,
        "ipfs://QmExtended",
        extendedMetadata
      );

      const receipt = await tx.wait();
      const agentCreatedEvent = receipt.events.find(e => e.event === 'AgentCreated');
      expect(agentCreatedEvent).to.not.be.undefined;
    });

    it('Should reject unapproved template', async function () {
      const unapprovedLogic = await MockAgentLogic.deploy(
        bep007Enhanced.address,
        "Unapproved Agent",
        "Description",
        "Experience",
        ["capability"],
        ["domain.com"]
      );
      await unapprovedLogic.deployed();

      await expect(
        agentFactory.connect(addr1)["createAgent(string,string,address,string)"](
          "Test Agent",
          "TA",
          unapprovedLogic.address,
          "ipfs://QmTest"
        )
      ).to.be.revertedWith("AgentFactory: logic template not approved");
    });
  });

  describe('Enhanced Agent Creation with Learning', function () {
    it('Should create an agent with learning enabled', async function () {
      const extendedMetadata = {
        persona: 'Learning Persona',
        experience: 'Learning Experience',
        voiceHash: 'Learning Voice Hash',
        animationURI: 'ipfs://QmLearningAnimation',
        vaultURI: 'ipfs://QmLearningVault',
        vaultHash: ethers.utils.formatBytes32String('learning-vault-hash'),
      };

      const params = {
        name: "Learning Agent",
        symbol: "LA",
        logicAddress: mockAgentLogic.address,
        metadataURI: "ipfs://QmLearning",
        extendedMetadata: extendedMetadata,
        enableLearning: true,
        learningModule: merkleTreeLearning.address,
        initialLearningRoot: ethers.utils.formatBytes32String('initial-root'),
        learningSignature: "0x"
      };

      const tx = await agentFactory.connect(addr1).createAgentWithLearning(params);
      const receipt = await tx.wait();

      const agentCreatedEvent = receipt.events.find(e => e.event === 'AgentCreated');
      expect(agentCreatedEvent.args.learningEnabled).to.be.true;
      expect(agentCreatedEvent.args.learningModule).to.equal(merkleTreeLearning.address);

      const learningEnabledEvent = receipt.events.find(e => e.event === 'AgentLearningEnabled');
      expect(learningEnabledEvent).to.not.be.undefined;
    });

    it('Should create an agent with learning disabled', async function () {
      const extendedMetadata = {
        persona: 'Non-Learning Persona',
        experience: 'Non-Learning Experience',
        voiceHash: 'Non-Learning Voice Hash',
        animationURI: 'ipfs://QmNonLearningAnimation',
        vaultURI: 'ipfs://QmNonLearningVault',
        vaultHash: ethers.utils.formatBytes32String('non-learning-vault-hash'),
      };

      const params = {
        name: "Non-Learning Agent",
        symbol: "NLA",
        logicAddress: mockAgentLogic.address,
        metadataURI: "ipfs://QmNonLearning",
        extendedMetadata: extendedMetadata,
        enableLearning: false,
        learningModule: ethers.constants.AddressZero,
        initialLearningRoot: ethers.constants.HashZero,
        learningSignature: "0x"
      };

      const tx = await agentFactory.connect(addr1).createAgentWithLearning(params);
      const receipt = await tx.wait();

      const agentCreatedEvent = receipt.events.find(e => e.event === 'AgentCreated');
      expect(agentCreatedEvent.args.learningEnabled).to.be.false;
      expect(agentCreatedEvent.args.learningModule).to.equal(ethers.constants.AddressZero);

      const learningEnabledEvent = receipt.events.find(e => e.event === 'AgentLearningEnabled');
      expect(learningEnabledEvent).to.be.undefined;
    });

    it('Should reject unapproved learning module', async function () {
      const unapprovedModule = await upgrades.deployProxy(
        MerkleTreeLearning,
        [bep007Enhanced.address],
        { initializer: "initialize" }
      );
      await unapprovedModule.deployed();

      const extendedMetadata = {
        persona: 'Test Persona',
        experience: 'Test Experience',
        voiceHash: 'Test Voice Hash',
        animationURI: 'ipfs://QmTestAnimation',
        vaultURI: 'ipfs://QmTestVault',
        vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
      };

      const params = {
        name: "Test Agent",
        symbol: "TA",
        logicAddress: mockAgentLogic.address,
        metadataURI: "ipfs://QmTest",
        extendedMetadata: extendedMetadata,
        enableLearning: true,
        learningModule: unapprovedModule.address,
        initialLearningRoot: ethers.utils.formatBytes32String('initial-root'),
        learningSignature: "0x"
      };

      await expect(
        agentFactory.connect(addr1).createAgentWithLearning(params)
      ).to.be.revertedWith("AgentFactory: learning module not approved");
    });
  });

  describe('Batch Agent Creation', function () {
    it('Should create multiple agents in batch', async function () {
      const extendedMetadata = {
        persona: 'Batch Persona',
        experience: 'Batch Experience',
        voiceHash: 'Batch Voice Hash',
        animationURI: 'ipfs://QmBatchAnimation',
        vaultURI: 'ipfs://QmBatchVault',
        vaultHash: ethers.utils.formatBytes32String('batch-vault-hash'),
      };

      const params1 = {
        name: "Batch Agent 1",
        symbol: "BA1",
        logicAddress: mockAgentLogic.address,
        metadataURI: "ipfs://QmBatch1",
        extendedMetadata: extendedMetadata,
        enableLearning: true,
        learningModule: merkleTreeLearning.address,
        initialLearningRoot: ethers.utils.formatBytes32String('batch-root-1'),
        learningSignature: "0x"
      };

      const params2 = {
        name: "Batch Agent 2",
        symbol: "BA2",
        logicAddress: mockAgentLogic.address,
        metadataURI: "ipfs://QmBatch2",
        extendedMetadata: extendedMetadata,
        enableLearning: false,
        learningModule: ethers.constants.AddressZero,
        initialLearningRoot: ethers.constants.HashZero,
        learningSignature: "0x"
      };

      const agents = await agentFactory.connect(addr1).batchCreateAgentsWithLearning([params1, params2]);
      const receipt = await agents.wait();

      const agentCreatedEvents = receipt.events.filter(e => e.event === 'AgentCreated');
      expect(agentCreatedEvents).to.have.length(2);

      // Verify global stats updated
      const stats = await agentFactory.getGlobalLearningStats();
      expect(stats.totalAgentsCreated).to.equal(2);
      expect(stats.totalLearningEnabledAgents).to.equal(1); // Only first agent has learning enabled
    });

    it('Should reject empty batch', async function () {
      await expect(
        agentFactory.connect(addr1).batchCreateAgentsWithLearning([])
      ).to.be.revertedWith("AgentFactory: empty params array");
    });

    it('Should reject batch with too many agents', async function () {
      const extendedMetadata = {
        persona: 'Test Persona',
        experience: 'Test Experience',
        voiceHash: 'Test Voice Hash',
        animationURI: 'ipfs://QmTestAnimation',
        vaultURI: 'ipfs://QmTestVault',
        vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
      };

      const params = {
        name: "Test Agent",
        symbol: "TA",
        logicAddress: mockAgentLogic.address,
        metadataURI: "ipfs://QmTest",
        extendedMetadata: extendedMetadata,
        enableLearning: false,
        learningModule: ethers.constants.AddressZero,
        initialLearningRoot: ethers.constants.HashZero,
        learningSignature: "0x"
      };

      const largeBatch = new Array(11).fill(params);

      await expect(
        agentFactory.connect(addr1).batchCreateAgentsWithLearning(largeBatch)
      ).to.be.revertedWith("AgentFactory: too many agents in batch");
    });
  });

  describe('Learning Analytics', function () {
    let agentAddress;

    beforeEach(async function () {
      const tx = await bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("createAgent(string,string,address,string)",
        ["Analytics Agent",
        "AA",
        mockAgentLogic.address,
        "ipfs://QmAnalytics"]
      ));
      const receipt = await tx.wait();
      const agentCreatedEvent = receipt.events.find(e => e.event === 'AgentCreated');
      agentAddress = agentCreatedEvent.args.agent;
    });

    it('Should track agent learning analytics', async function () {
      const analytics = await agentFactory.getAgentLearningAnalytics(agentAddress);
      expect(analytics.totalAgents).to.equal(1);
      expect(analytics.learningEnabledAgents).to.equal(1);
      expect(analytics.totalInteractions).to.equal(0);
      expect(analytics.averageConfidenceScore).to.equal(0);
    });

    it('Should enable learning for existing agent', async function () {
      // First create an agent without learning
      await agentFactory.setLearningPaused(true); // Disable default learning
      const tx = await agentFactory.connect(addr2)["createAgent(string,string,address,string)"](
        "Non-Learning Agent",
        "NLA",
        mockAgentLogic.address,
        "ipfs://QmNonLearning"
      );
      const receipt = await tx.wait();
      const agentCreatedEvent = receipt.events.find(e => e.event === 'AgentCreated');
      const nonLearningAgentAddress = agentCreatedEvent.args.agent;

      // Re-enable learning
      await agentFactory.setLearningPaused(false);

      // Enable learning for the agent
      await expect(
        agentFactory.connect(addr2).enableAgentLearning(
          nonLearningAgentAddress,
          1, // tokenId
          merkleTreeLearning.address,
          ethers.utils.formatBytes32String('new-root')
        )
      ).to.emit(agentFactory, 'AgentLearningEnabled');
    });
  });

  describe('Configuration Management', function () {
    it('Should update learning configuration', async function () {
      const newConfig = {
        learningEnabledByDefault: false,
        minConfidenceThreshold: ethers.utils.parseEther('0.7'),
        maxLearningModulesPerAgent: 5,
        learningAnalyticsUpdateInterval: 43200, // 12 hours
        requireSignatureForLearning: true
      };

      await expect(bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("updateLearningConfig", [newConfig])))
        .to.emit(agentFactory, 'LearningConfigUpdated');

      const updatedConfig = await agentFactory.getLearningConfig();
      expect(updatedConfig.learningEnabledByDefault).to.equal(newConfig.learningEnabledByDefault);
      expect(updatedConfig.minConfidenceThreshold).to.equal(newConfig.minConfidenceThreshold);
      expect(updatedConfig.maxLearningModulesPerAgent).to.equal(newConfig.maxLearningModulesPerAgent);
      expect(updatedConfig.learningAnalyticsUpdateInterval).to.equal(newConfig.learningAnalyticsUpdateInterval);
      expect(updatedConfig.requireSignatureForLearning).to.equal(newConfig.requireSignatureForLearning);
    });

    it('Should set default learning module', async function () {
      const newLearningModule = await upgrades.deployProxy(
        MerkleTreeLearning,
        [bep007Enhanced.address],
        { initializer: "initialize" }
      );
      await newLearningModule.deployed();

      // First approve the new module
      await bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("approveLearningModule", [newLearningModule.address, "new_default", "1.0.0"]));

      // Then set it as default
      await bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setDefaultLearningModule", [newLearningModule.address]));
      expect(await agentFactory.defaultLearningModule()).to.equal(newLearningModule.address);
    });

    it('Should update implementation address', async function () {
      const newImplementation = await upgrades.deployProxy(
        BEP007Enhanced,
        ["New Enhanced NFA", "NENFA", circuitBreaker.address],
        { initializer: "initialize", kind: "uups" }
      );
      await newImplementation.deployed();

      await bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setImplementation", [newImplementation.address]));
      expect(await agentFactory.implementation()).to.equal(newImplementation.address);
    });

    it('Should update governance address', async function () {
      const newGovernance = await upgrades.deployProxy(
        CircuitBreaker,
        [owner.address, owner.address],
        { initializer: "initialize"}
      );
      await newGovernance.deployed();

      await bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setGovernance", [newGovernance.address]));
      expect(await agentFactory.governance()).to.equal(newGovernance.address);
    });

    it('Should pause learning functionality', async function () {
      await expect(bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setLearningPaused", [true])))
        .to.emit(agentFactory, 'LearningConfigUpdated');

      const config = await agentFactory.getLearningConfig();
      expect(config.learningEnabledByDefault).to.be.false;
    });
  });

  describe('Access Control', function () {
    it('Should only allow governance to approve templates', async function () {
      const newMockLogic = await MockAgentLogic.deploy(
        bep007Enhanced.address,
        "Unauthorized Template",
        "Description",
        "Experience",
        ["capability"],
        ["domain.com"]
      );
      await newMockLogic.deployed();

      await expect(
       agentFactory.approveTemplate(newMockLogic.address, "unauthorized", "1.0.0")
      ).to.be.revertedWith("AgentFactory: caller is not governance");
    });

    it('Should only allow governance to update configuration', async function () {
      const newConfig = {
        learningEnabledByDefault: false,
        minConfidenceThreshold: ethers.utils.parseEther('0.8'),
        maxLearningModulesPerAgent: 2,
        learningAnalyticsUpdateInterval: 3600,
        requireSignatureForLearning: true
      };

      await expect(
        agentFactory.connect(addr1).updateLearningConfig(newConfig)
      ).to.be.revertedWith("AgentFactory: caller is not governance");
    });

    it('Should only allow owner to authorize upgrade', async function () {
      const newImplementation = await AgentFactory.deploy();
      await newImplementation.deployed();

      await expect(
        agentFactory.connect(addr1).upgradeTo(newImplementation.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe('Error Handling', function () {
    it('Should reject zero address implementation', async function () {
      await expect(
        bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setImplementation", [ethers.constants.AddressZero]))
      ).to.be.revertedWith("AgentFactory: implementation is zero address");
    });

    it('Should reject zero address governance', async function () {
      await expect(
        bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setGovernance", [ethers.constants.AddressZero]))
      ).to.be.revertedWith("AgentFactory: governance is zero address");
    });

    it('Should reject zero address learning module', async function () {
      await expect(
        bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("approveLearningModule", [ethers.constants.AddressZero, "zero", "1.0.0"]))
      ).to.be.revertedWith("AgentFactory: learning module is zero address");
    });

    it('Should reject setting unapproved default learning module', async function () {
      const unapprovedModule = await upgrades.deployProxy(
        MerkleTreeLearning,
        [bep007Enhanced.address],
        { initializer: "initialize" }
      );
      await unapprovedModule.deployed();

      await expect(
        bep007Governance.executeAction(
       agentFactory.address,
       agentFactory.interface.encodeFunctionData("setDefaultLearningModule", [unapprovedModule.address]))
      ).to.be.revertedWith("AgentFactory: module not approved");
    });

    it('Should handle non-existent template category', async function () {
      await expect(
        agentFactory.getLatestTemplate("non_existent")
      ).to.be.revertedWith("AgentFactory: no template for category");
    });

    it('Should handle non-existent learning module category', async function () {
      await expect(
        agentFactory.getLatestLearningModule("non_existent")
      ).to.be.revertedWith("AgentFactory: no learning module for category");
    });
  });
});
