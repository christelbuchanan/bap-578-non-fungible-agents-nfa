const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("BEP007", function () {
  let BEP007;
  let MemoryModuleRegistry;
  let VaultPermissionManager;
  let bep007;
  let memoryRegistry;
  let vaultManager;
  let governance;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get signers
    [owner, governance, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Deploy BEP007
    BEP007 = await ethers.getContractFactory("BEP007");
    bep007 = await upgrades.deployProxy(BEP007, ["Non-Fungible Agent", "NFA", governance.address]);
    await bep007.deployed();

    // Deploy MemoryModuleRegistry
    MemoryModuleRegistry = await ethers.getContractFactory("MemoryModuleRegistry");
    memoryRegistry = await upgrades.deployProxy(MemoryModuleRegistry, [bep007.address]);
    await memoryRegistry.deployed();

    // Deploy VaultPermissionManager
    VaultPermissionManager = await ethers.getContractFactory("VaultPermissionManager");
    vaultManager = await upgrades.deployProxy(VaultPermissionManager, [bep007.address]);
    await vaultManager.deployed();

    // Set memory module registry in BEP007
    await bep007.connect(governance).setMemoryModuleRegistry(memoryRegistry.address);
  });

  describe("Agent Creation", function () {
    it("Should create an agent with basic metadata", async function () {
      // Create a mock logic contract
      const MockLogic = await ethers.getContractFactory("MockAgentLogic");
      const mockLogic = await MockLogic.deploy();
      await mockLogic.deployed();

      // Create agent
      const metadataURI = "ipfs://QmXyz...";
      const tx = await bep007.createAgent(addr1.address, mockLogic.address, metadataURI);
      const receipt = await tx.wait();
      
      // Get token ID from event
      const event = receipt.events.find(e => e.event === "Transfer");
      const tokenId = event.args.tokenId;

      // Check agent state
      const state = await bep007.getState(tokenId);
      expect(state.owner).to.equal(addr1.address);
      expect(state.logicAddress).to.equal(mockLogic.address);
      expect(state.status).to.equal(0); // Active
      
      // Check token URI
      expect(await bep007.tokenURI(tokenId)).to.equal(metadataURI);
    });

    it("Should create an agent with extended metadata", async function () {
      // Create a mock logic contract
      const MockLogic = await ethers.getContractFactory("MockAgentLogic");
      const mockLogic = await MockLogic.deploy();
      await mockLogic.deployed();

      // Create extended metadata
      const extendedMetadata = {
        persona: "Strategic crypto analyst",
        memory: "crypto intelligence, FUD scanner",
        voiceHash: "bafkreigh2akiscaildc...",
        animationURI: "ipfs://Qm.../nfa007_intro.mp4",
        vaultURI: "ipfs://Qm.../nfa007_vault.json",
        vaultHash: ethers.utils.keccak256(ethers.utils.toUtf8Bytes("vault_content"))
      };

      // Create agent
      const metadataURI = "ipfs://QmXyz...";
      const tx = await bep007.createAgent(
        addr1.address, 
        mockLogic.address, 
        metadataURI,
        extendedMetadata
      );
      const receipt = await tx.wait();
      
      // Get token ID from event
      const event = receipt.events.find(e => e.event === "Transfer");
      const tokenId = event.args.tokenId;

      // Check extended metadata
      const metadata = await bep007.getAgentMetadata(tokenId);
      expect(metadata.persona).to.equal(extendedMetadata.persona);
      expect(metadata.memory).to.equal(extendedMetadata.memory);
      expect(metadata.voiceHash).to.equal(extendedMetadata.voiceHash);
      expect(metadata.animationURI).to.equal(extendedMetadata.animationURI);
      expect(metadata.vaultURI).to.equal(extendedMetadata.vaultURI);
      expect(metadata.vaultHash).to.equal(extendedMetadata.vaultHash);
    });
  });

  describe("Memory Module Registry", function () {
    it("Should register a memory module", async function () {
      // Create agent
      const MockLogic = await ethers.getContractFactory("MockAgentLogic");
      const mockLogic = await MockLogic.deploy();
      const metadataURI = "ipfs://QmXyz...";
      const tx = await bep007.createAgent(addr1.address, mockLogic.address, metadataURI);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "Transfer");
      const tokenId = event.args.tokenId;

      // Create a mock memory module
      const moduleAddress = addrs[0].address;
      const moduleMetadata = JSON.stringify({
        context_id: "nfa007-memory-001",
        owner: addr1.address,
        created: "2025-05-12T10:00:00Z",
        persona: "Strategic crypto analyst"
      });

      // Sign the registration
      const messageHash = ethers.utils.solidityKeccak256(
        ["uint256", "address", "string"],
        [tokenId, moduleAddress, moduleMetadata]
      );
      const signature = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // Register the module
      await memoryRegistry.connect(addr1).registerModule(
        tokenId,
        moduleAddress,
        moduleMetadata,
        signature
      );

      // Check if module is registered
      expect(await memoryRegistry.isModuleApproved(tokenId, moduleAddress)).to.be.true;
      expect(await memoryRegistry.getModuleMetadata(tokenId, moduleAddress)).to.equal(moduleMetadata);
      
      const modules = await memoryRegistry.getRegisteredModules(tokenId);
      expect(modules).to.include(moduleAddress);
    });
  });

  describe("Vault Permission Management", function () {
    it("Should delegate vault access", async function () {
      // Create agent
      const MockLogic = await ethers.getContractFactory("MockAgentLogic");
      const mockLogic = await MockLogic.deploy();
      const metadataURI = "ipfs://QmXyz...";
      const tx = await bep007.createAgent(addr1.address, mockLogic.address, metadataURI);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "Transfer");
      const tokenId = event.args.tokenId;

      // Delegate access
      const delegate = addr2.address;
      const expiryTime = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
      
      // Sign the delegation
      const messageHash = ethers.utils.solidityKeccak256(
        ["uint256", "address", "uint256"],
        [tokenId, delegate, expiryTime]
      );
      const signature = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // Delegate access
      await vaultManager.connect(addr1).delegateAccess(
        tokenId,
        delegate,
        expiryTime,
        signature
      );

      // Check if access is delegated
      expect(await vaultManager.hasVaultAccess(tokenId, delegate)).to.be.true;
      expect(await vaultManager.getDelegationExpiry(tokenId, delegate)).to.equal(expiryTime);
    });

    it("Should revoke vault access", async function () {
      // Create agent
      const MockLogic = await ethers.getContractFactory("MockAgentLogic");
      const mockLogic = await MockLogic.deploy();
      const metadataURI = "ipfs://QmXyz...";
      const tx = await bep007.createAgent(addr1.address, mockLogic.address, metadataURI);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "Transfer");
      const tokenId = event.args.tokenId;

      // Delegate access
      const delegate = addr2.address;
      const expiryTime = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
      
      // Sign the delegation
      const messageHash = ethers.utils.solidityKeccak256(
        ["uint256", "address", "uint256"],
        [tokenId, delegate, expiryTime]
      );
      const signature = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // Delegate access
      await vaultManager.connect(addr1).delegateAccess(
        tokenId,
        delegate,
        expiryTime,
        signature
      );

      // Revoke access
      await vaultManager.connect(addr1).revokeAccess(tokenId, delegate);

      // Check if access is revoked
      expect(await vaultManager.hasVaultAccess(tokenId, delegate)).to.be.false;
      expect(await vaultManager.getDelegationExpiry(tokenId, delegate)).to.equal(0);
    });
  });
});
