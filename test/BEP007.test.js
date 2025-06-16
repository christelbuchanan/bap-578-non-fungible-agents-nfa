const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('BEP007 Non-Fungible Agent', function () {
  let BEP007;
  let bep007;
  let MockAgentLogic;
  let mockAgentLogic;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers
    BEP007 = await ethers.getContractFactory('BEP007');
    MockAgentLogic = await ethers.getContractFactory('MockAgentLogic');
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Deploy BEP007 first since MockAgentLogic needs its address
    bep007 = await BEP007.deploy();
    await bep007.deployed();
    await bep007.initialize('Non-Fungible Agent', 'NFA', owner.address);

    // Deploy MockAgentLogic with required constructor arguments
    mockAgentLogic = await MockAgentLogic.deploy(
      bep007.address, // agentToken
      'Test Agent', // name
      'A test agent for BEP007', // description
      'Testing and validation', // experience
      ['testing', 'validation'], // capabilities
      ['unit_testing', 'integration_testing'], // learningDomains
    );
    await mockAgentLogic.deployed();
  });

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      expect(await bep007.owner()).to.equal(owner.address);
    });

    it('Should set the right name and symbol', async function () {
      expect(await bep007.name()).to.equal('Non-Fungible Agent');
      expect(await bep007.symbol()).to.equal('NFA');
    });
  });

  describe('Agent Creation', function () {
    it('Should create an agent with the correct metadata', async function () {
      const metadataURI = 'ipfs://QmTest';
      const extendedMetadata = {
        persona: 'Test Persona',
        experience: 'Test Experience',
        voiceHash: 'Test Voice Hash',
        animationURI: 'ipfs://QmTestAnimation',
        vaultURI: 'ipfs://QmTestVault',
        vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
      };

      await expect(
        bep007.createAgent(addr1.address, mockAgentLogic.address, metadataURI, extendedMetadata),
      )
        .to.emit(bep007, 'Transfer')
        .withArgs(ethers.constants.AddressZero, addr1.address, 1);

      const tokenId = 1; // First token ID
      expect(await bep007.ownerOf(tokenId)).to.equal(addr1.address);
      expect(await bep007.tokenURI(tokenId)).to.equal(metadataURI);

      const agentMetadata = await bep007.getAgentMetadata(tokenId);
      expect(agentMetadata.persona).to.equal(extendedMetadata.persona);
      expect(agentMetadata.experience).to.equal(extendedMetadata.experience);
      expect(agentMetadata.voiceHash).to.equal(extendedMetadata.voiceHash);
      expect(agentMetadata.animationURI).to.equal(extendedMetadata.animationURI);
      expect(agentMetadata.vaultURI).to.equal(extendedMetadata.vaultURI);
      expect(agentMetadata.vaultHash).to.equal(extendedMetadata.vaultHash);

      const agentState = await bep007.getState(tokenId);
      expect(agentState.logicAddress).to.equal(mockAgentLogic.address);
      expect(agentState.status).to.equal(0); // Status.Active = 0
      expect(agentState.balance).to.equal(0);
    });
  });

  describe('Agent Actions', function () {
    let tokenId;

    beforeEach(async function () {
      // Create an agent for testing
      const metadataURI = 'ipfs://QmTest';
      const extendedMetadata = {
        persona: 'Test Persona',
        experience: 'Test Experience',
        voiceHash: 'Test Voice Hash',
        animationURI: 'ipfs://QmTestAnimation',
        vaultURI: 'ipfs://QmTestVault',
        vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
      };

      await bep007.createAgent(
        addr1.address,
        mockAgentLogic.address,
        metadataURI,
        extendedMetadata,
      );

      tokenId = 1; // First token ID

      // Fund the agent
      await bep007.connect(addr1).fundAgent(tokenId, { value: ethers.utils.parseEther('0.5') });
    });

    it('Should execute an action successfully', async function () {
      const data = mockAgentLogic.interface.encodeFunctionData('testAction', [42]);

      await expect(bep007.connect(addr1).executeAction(tokenId, data))
        .to.emit(bep007, 'ActionExecuted')
        .withArgs(bep007.address, ethers.utils.defaultAbiCoder.encode(['uint256'], [42]));

      const agentState = await bep007.getState(tokenId);
      expect(agentState.lastActionTimestamp).to.be.gt(0);
    });

    it('Should fail to execute action when agent is paused', async function () {
      await bep007.connect(addr1).setAgentActive(tokenId, false);

      const data = mockAgentLogic.interface.encodeFunctionData('testAction', [42]);
      await expect(bep007.connect(addr1).executeAction(tokenId, data)).to.be.revertedWith(
        'BEP007: agent not active',
      );
    });

    it('Should update logic address', async function () {
      const NewMockAgentLogic = await ethers.getContractFactory('MockAgentLogic');
      const newMockAgentLogic = await NewMockAgentLogic.deploy();
      await newMockAgentLogic.deployed();

      await expect(bep007.connect(addr1).setLogicAddress(tokenId, newMockAgentLogic.address))
        .to.emit(bep007, 'LogicUpgraded')
        .withArgs(bep007.address, mockAgentLogic.address, newMockAgentLogic.address);

      const agentState = await bep007.getState(tokenId);
      expect(agentState.logicAddress).to.equal(newMockAgentLogic.address);
    });

    it('Should update agent metadata', async function () {
      const newMetadata = {
        persona: 'Updated Persona',
        experience: 'Updated Experience',
        voiceHash: 'Updated Voice Hash',
        animationURI: 'ipfs://QmUpdatedAnimation',
        vaultURI: 'ipfs://QmUpdatedVault',
        vaultHash: ethers.utils.formatBytes32String('updated-vault-hash'),
      };

      await expect(bep007.connect(addr1).updateAgentMetadata(tokenId, newMetadata))
        .to.emit(bep007, 'MetadataUpdated')
        .withArgs(tokenId, await bep007.tokenURI(tokenId));

      const agentMetadata = await bep007.getAgentMetadata(tokenId);
      expect(agentMetadata.persona).to.equal(newMetadata.persona);
      expect(agentMetadata.experience).to.equal(newMetadata.experience);
      expect(agentMetadata.voiceHash).to.equal(newMetadata.voiceHash);
      expect(agentMetadata.animationURI).to.equal(newMetadata.animationURI);
      expect(agentMetadata.vaultURI).to.equal(newMetadata.vaultURI);
      expect(agentMetadata.vaultHash).to.equal(newMetadata.vaultHash);
    });

    it('Should handle agent funding correctly', async function () {
      const fundingAmount = ethers.utils.parseEther('1.0');

      await expect(bep007.connect(addr1).fundAgent(tokenId, { value: fundingAmount }))
        .to.emit(bep007, 'AgentFunded')
        .withArgs(bep007.address, addr1.address, fundingAmount);

      const agentState = await bep007.getState(tokenId);
      expect(agentState.balance).to.equal(fundingAmount.add(ethers.utils.parseEther('0.5')));
    });

    it('Should allow owner to withdraw funds', async function () {
      const withdrawAmount = ethers.utils.parseEther('0.2');
      const initialBalance = await addr1.getBalance();

      await bep007.connect(addr1).withdrawFromAgent(tokenId, withdrawAmount);

      const agentState = await bep007.getState(tokenId);
      expect(agentState.balance).to.equal(ethers.utils.parseEther('0.3')); // 0.5 - 0.2

      const finalBalance = await addr1.getBalance();
      expect(finalBalance).to.be.gt(initialBalance);
    });
  });

  describe('Agent Status Management', function () {
    let tokenId;

    beforeEach(async function () {
      const metadataURI = 'ipfs://QmTest';
      const extendedMetadata = {
        persona: 'Test Persona',
        experience: 'Test Experience',
        voiceHash: 'Test Voice Hash',
        animationURI: 'ipfs://QmTestAnimation',
        vaultURI: 'ipfs://QmTestVault',
        vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
      };

      await bep007.createAgent(
        addr1.address,
        mockAgentLogic.address,
        metadataURI,
        extendedMetadata,
      );

      tokenId = 1;
    });

    it('Should allow owner to pause and unpause agent', async function () {
      await expect(bep007.connect(addr1).setAgentActive(tokenId, false))
        .to.emit(bep007, 'StatusChanged')
        .withArgs(bep007.address, 1); // Status.Paused = 1

      let agentState = await bep007.getState(tokenId);
      expect(agentState.status).to.equal(1); // Status.Paused

      await expect(bep007.connect(addr1).setAgentActive(tokenId, true))
        .to.emit(bep007, 'StatusChanged')
        .withArgs(bep007.address, 0); // Status.Active = 0

      agentState = await bep007.getState(tokenId);
      expect(agentState.status).to.equal(0); // Status.Active
    });

    it('Should prevent non-owner from changing agent status', async function () {
      await expect(bep007.connect(addr2).setAgentActive(tokenId, false)).to.be.revertedWith(
        'BEP007: caller is not owner',
      );
    });
  });
});
