const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('BEP007 Non-Fungible Agent', function () {
  let BEP007;
  let bep007;
  let CircuitBreaker;
  let circuitBreaker;
  let MockAgentLogic;
  let mockAgentLogic;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers

    const GOVERNANCE_ADDRESS = "0xa2d6b96D1D0A4966546B8D4c5EaA050bc27778ad"; // governance contract address
    const MULTISIG_ADDRESS = "0xd27dbd7b311A2f8607737d0cb8d1Defbe4B3A9ca";   // emergency multi-sig wallet address
  
    const CircuitBreakerFactory = await ethers.getContractFactory("CircuitBreaker");
    CircuitBreaker = await upgrades.deployProxy(
      CircuitBreakerFactory,
      [GOVERNANCE_ADDRESS, MULTISIG_ADDRESS],
      { initializer: "initialize" }
    );
    await CircuitBreaker.deployed();


    const NAME = "Non-Fungible Agent";
    const SYMBOL = "NFA";
  
  
    const BEP007Factory = await ethers.getContractFactory("BEP007");
  
    bep007 = await upgrades.deployProxy(
      BEP007Factory,
      [NAME, SYMBOL, GOVERNANCE_ADDRESS],
      { initializer: "initialize", kind: "uups" }
    );
    await bep007.deployed();


    // BEP007 = await ethers.getContractFactory('BEP007');
    // MockAgentLogic = await ethers.getContractFactory('MockAgentLogic');
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // // Deploy CircuitBreaker
    // circuitBreaker = await CircuitBreaker.deploy();
    // await circuitBreaker.deployed();

    // // Deploy MockAgentLogic
    // mockAgentLogic = await MockAgentLogic.deploy();
    // await mockAgentLogic.deployed();

    // // Deploy BEP007 with CircuitBreaker
    // bep007 = await BEP007.deploy('Non-Fungible Agent', 'NFA', circuitBreaker.address);
    // await bep007.deployed();
  });

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      console.log("owner ==>", await bep007.owner())
      expect(await bep007.owner()).to.equal(owner.address);
    });

    it('Should set the right name and symbol', async function () {
      expect(await bep007.name()).to.equal('Non-Fungible Agent');
      expect(await bep007.symbol()).to.equal('NFA');
    });

    // it('Should set the right circuit breaker', async function () {
    //   expect(await bep007.circuitBreaker()).to.equal(CircuitBreaker.address);
    // });

  });

  // describe('Agent Creation', function () {
  //   it('Should create an agent with the correct metadata', async function () {
  //     const metadataURI = 'ipfs://QmTest';
  //     const extendedMetadata = {
  //       persona: 'Test Persona',
  //       experience: 'Test Experience',
  //       voiceHash: 'Test Voice Hash',
  //       animationURI: 'ipfs://QmTestAnimation',
  //       vaultURI: 'ipfs://QmTestVault',
  //       vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
  //     };

  //     await bep007.createAgent(
  //       addr1.address,
  //       mockAgentLogic.address,
  //       metadataURI,
  //       extendedMetadata,
  //     );

  //     const tokenId = 1; // First token ID
  //     expect(await bep007.ownerOf(tokenId)).to.equal(addr1.address);
  //     expect(await bep007.tokenURI(tokenId)).to.equal(metadataURI);

  //     const agentMetadata = await bep007.getAgentMetadata(tokenId);
  //     expect(agentMetadata.persona).to.equal(extendedMetadata.persona);
  //     expect(agentMetadata.experience).to.equal(extendedMetadata.experience);
  //     expect(agentMetadata.voiceHash).to.equal(extendedMetadata.voiceHash);
  //     expect(agentMetadata.animationURI).to.equal(extendedMetadata.animationURI);
  //     expect(agentMetadata.vaultURI).to.equal(extendedMetadata.vaultURI);
  //     expect(agentMetadata.vaultHash).to.equal(extendedMetadata.vaultHash);

  //     const agentState = await bep007.getState(tokenId);
  //     expect(agentState.logicAddress).to.equal(mockAgentLogic.address);
  //     expect(agentState.active).to.be.true;
  //   });
  // });

  // describe('Agent Actions', function () {
  //   let tokenId;

  //   beforeEach(async function () {
  //     // Create an agent for testing
  //     const metadataURI = 'ipfs://QmTest';
  //     const extendedMetadata = {
  //       persona: 'Test Persona',
  //       experience: 'Test Experience',
  //       voiceHash: 'Test Voice Hash',
  //       animationURI: 'ipfs://QmTestAnimation',
  //       vaultURI: 'ipfs://QmTestVault',
  //       vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
  //     };

  //     await bep007.createAgent(
  //       addr1.address,
  //       mockAgentLogic.address,
  //       metadataURI,
  //       extendedMetadata,
  //     );

  //     tokenId = 1; // First token ID

  //     // Fund the agent
  //     await addr1.sendTransaction({
  //       to: bep007.address,
  //       value: ethers.utils.parseEther('1.0'),
  //     });
  //     await bep007.connect(addr1).fundAgent(tokenId, { value: ethers.utils.parseEther('0.5') });
  //   });

  //   it('Should execute an action successfully', async function () {
  //     // Encode the function call to the mock agent's testAction method
  //     const data = mockAgentLogic.interface.encodeFunctionData('testAction', [42]);

  //     // Execute the action
  //     await bep007.connect(addr1).executeAction(tokenId, data);

  //     // Verify the action was executed (this would check a state change in a real test)
  //     // For this mock test, we're just ensuring it doesn't revert
  //   });

  //   it('Should update logic address', async function () {
  //     // Deploy a new logic contract
  //     const NewMockAgentLogic = await ethers.getContractFactory('MockAgentLogic');
  //     const newMockAgentLogic = await NewMockAgentLogic.deploy();
  //     await newMockAgentLogic.deployed();

  //     // Update the logic address
  //     await bep007.connect(addr1).setLogicAddress(tokenId, newMockAgentLogic.address);

  //     // Verify the logic address was updated
  //     const agentState = await bep007.getState(tokenId);
  //     expect(agentState.logicAddress).to.equal(newMockAgentLogic.address);
  //   });

  //   it('Should update agent metadata', async function () {
  //     const newMetadata = {
  //       persona: 'Updated Persona',
  //       experience: 'Updated Experience',
  //       voiceHash: 'Updated Voice Hash',
  //       animationURI: 'ipfs://QmUpdatedAnimation',
  //       vaultURI: 'ipfs://QmUpdatedVault',
  //       vaultHash: ethers.utils.formatBytes32String('updated-vault-hash'),
  //     };

  //     // Update the metadata
  //     await bep007.connect(addr1).updateAgentMetadata(tokenId, newMetadata);

  //     // Verify the metadata was updated
  //     const agentMetadata = await bep007.getAgentMetadata(tokenId);
  //     expect(agentMetadata.persona).to.equal(newMetadata.persona);
  //     expect(agentMetadata.experience).to.equal(newMetadata.experience);
  //     expect(agentMetadata.voiceHash).to.equal(newMetadata.voiceHash);
  //     expect(agentMetadata.animationURI).to.equal(newMetadata.animationURI);
  //     expect(agentMetadata.vaultURI).to.equal(newMetadata.vaultURI);
  //     expect(agentMetadata.vaultHash).to.equal(newMetadata.vaultHash);
  //   });
  // });

  // describe('Circuit Breaker', function () {
  //   let tokenId;

  //   beforeEach(async function () {
  //     // Create an agent for testing
  //     const metadataURI = 'ipfs://QmTest';
  //     const extendedMetadata = {
  //       persona: 'Test Persona',
  //       experience: 'Test Experience',
  //       voiceHash: 'Test Voice Hash',
  //       animationURI: 'ipfs://QmTestAnimation',
  //       vaultURI: 'ipfs://QmTestVault',
  //       vaultHash: ethers.utils.formatBytes32String('test-vault-hash'),
  //     };

  //     await bep007.createAgent(
  //       addr1.address,
  //       mockAgentLogic.address,
  //       metadataURI,
  //       extendedMetadata,
  //     );

  //     tokenId = 1; // First token ID
  //   });

  //   it('Should pause and unpause an agent', async function () {
  //     // Pause the agent
  //     await bep007.connect(addr1).setAgentActive(tokenId, false);

  //     // Verify the agent is paused
  //     const agentState = await bep007.getState(tokenId);
  //     expect(agentState.active).to.be.false;

  //     // Unpause the agent
  //     await bep007.connect(addr1).setAgentActive(tokenId, true);

  //     // Verify the agent is unpaused
  //     const updatedAgentState = await bep007.getState(tokenId);
  //     expect(updatedAgentState.active).to.be.true;
  //   });

  //   it('Should respect global circuit breaker', async function () {
  //     // Set global pause
  //     await circuitBreaker.setGlobalPause(true);

  //     // Try to execute an action (should fail)
  //     const data = mockAgentLogic.interface.encodeFunctionData('testAction', [42]);
  //     await expect(bep007.connect(addr1).executeAction(tokenId, data)).to.be.revertedWith(
  //       'CircuitBreaker: globally paused',
  //     );

  //     // Unpause
  //     await circuitBreaker.setGlobalPause(false);

  //     // Now it should work (assuming the agent is funded)
  //     await addr1.sendTransaction({
  //       to: bep007.address,
  //       value: ethers.utils.parseEther('1.0'),
  //     });
  //     await bep007.connect(addr1).fundAgent(tokenId, { value: ethers.utils.parseEther('0.5') });
  //     await bep007.connect(addr1).executeAction(tokenId, data);
  //   });
  // });
});
