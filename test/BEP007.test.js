const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("BEP007", function () {
  let BEP007;
  let bep007;
  let governance;
  let treasury;
  let agentFactory;
  let circuitBreaker;
  let owner;
  let user1;
  let user2;
  let daoAgent;
  let defiAgent;
  let gameAgent;

  beforeEach(async function () {
    // Get signers
    [owner, user1, user2, ...accounts] = await ethers.getSigners();

    // Deploy CircuitBreaker
    const CircuitBreaker = await ethers.getContractFactory("CircuitBreaker");
    circuitBreaker = await CircuitBreaker.deploy();
    await circuitBreaker.deployed();

    // Deploy BEP007 contract
    BEP007 = await ethers.getContractFactory("BEP007");
    bep007 = await upgrades.deployProxy(BEP007, ["Non-Fungible Agent", "NFA", owner.address], {
      initializer: "initialize",
      kind: "uups"
    });
    await bep007.deployed();

    // Deploy Governance contract
    const BEP007Governance = await ethers.getContractFactory("BEP007Governance");
    governance = await upgrades.deployProxy(
      BEP007Governance,
      ["BEP007 Governance", bep007.address, owner.address, 1, 10, 1],
      {
        initializer: "initialize",
        kind: "uups"
      }
    );
    await governance.deployed();

    // Deploy Treasury contract
    const BEP007Treasury = await ethers.getContractFactory("BEP007Treasury");
    treasury = await upgrades.deployProxy(
      BEP007Treasury,
      [governance.address, 1000, 2000], // 10% treasury fee, 20% owner fee
      {
        initializer: "initialize"
      }
    );
    await treasury.deployed();

    // Set governance in BEP007
    await bep007.setGovernance(governance.address);

    // Set treasury in governance
    await governance.setTreasury(treasury.address);

    // Deploy agent templates
    const DeFiAgent = await ethers.getContractFactory("DeFiAgent");
    defiAgent = await DeFiAgent.deploy();
    await defiAgent.deployed();

    const GameAgent = await ethers.getContractFactory("GameAgent");
    gameAgent = await GameAgent.deploy();
    await gameAgent.deployed();

    const DAOAgent = await ethers.getContractFactory("DAOAgent");
    daoAgent = await DAOAgent.deploy();
    await daoAgent.deployed();

    // Deploy AgentFactory
    const AgentFactory = await ethers.getContractFactory("AgentFactory");
    agentFactory = await AgentFactory.deploy(bep007.address);
    await agentFactory.deployed();

    // Set agent factory in governance
    await governance.setAgentFactory(agentFactory.address);
  });

  describe("Initialization", function () {
    it("Should initialize with correct name and symbol", async function () {
      expect(await bep007.name()).to.equal("Non-Fungible Agent");
      expect(await bep007.symbol()).to.equal("NFA");
    });

    it("Should set the correct governance address", async function () {
      expect(await bep007.governance()).to.equal(governance.address);
    });

    it("Should initialize with global pause disabled", async function () {
      expect(await bep007.globalPause()).to.equal(false);
    });
  });

  describe("Agent Creation", function () {
    it("Should create a new agent token", async function () {
      const tx = await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      
      const receipt = await tx.wait();
      
      // Check token ownership
      expect(await bep007.ownerOf(1)).to.equal(user1.address);
      
      // Check token URI
      expect(await bep007.tokenURI(1)).to.equal("ipfs://QmExample");
      
      // Check agent state
      const state = await bep007.getState(1);
      expect(state.balance).to.equal(0);
      expect(state.status).to.equal(0); // Active
      expect(state.owner).to.equal(user1.address);
      expect(state.logicAddress).to.equal(defiAgent.address);
    });

    it("Should fail to create agent with zero logic address", async function () {
      await expect(
        bep007.createAgent(user1.address, ethers.constants.AddressZero, "ipfs://QmExample")
      ).to.be.revertedWith("BEP007: logic address is zero");
    });
  });

  describe("Agent Funding", function () {
    let tokenId;

    beforeEach(async function () {
      const tx = await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const receipt = await tx.wait();
      tokenId = 1;
    });

    it("Should fund an agent with BNB", async function () {
      const fundAmount = ethers.utils.parseEther("1.0");
      
      await bep007.connect(user2).fundAgent(tokenId, { value: fundAmount });
      
      const state = await bep007.getState(tokenId);
      expect(state.balance).to.equal(fundAmount);
    });

    it("Should fail to fund non-existent agent", async function () {
      const fundAmount = ethers.utils.parseEther("1.0");
      
      await expect(
        bep007.connect(user2).fundAgent(999, { value: fundAmount })
      ).to.be.revertedWith("BEP007: agent does not exist");
    });
  });

  describe("Agent Logic", function () {
    let tokenId;

    beforeEach(async function () {
      const tx = await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const receipt = await tx.wait();
      tokenId = 1;
      
      // Fund the agent
      await bep007.connect(user2).fundAgent(tokenId, { 
        value: ethers.utils.parseEther("1.0") 
      });
    });

    it("Should update logic address", async function () {
      await bep007.connect(user1).setLogicAddress(tokenId, gameAgent.address);
      
      const state = await bep007.getState(tokenId);
      expect(state.logicAddress).to.equal(gameAgent.address);
    });

    it("Should fail to update logic if not owner", async function () {
      await expect(
        bep007.connect(user2).setLogicAddress(tokenId, gameAgent.address)
      ).to.be.revertedWith("BEP007: caller is not agent owner");
    });

    it("Should fail to update logic to zero address", async function () {
      await expect(
        bep007.connect(user1).setLogicAddress(tokenId, ethers.constants.AddressZero)
      ).to.be.revertedWith("BEP007: new logic address is zero");
    });
  });

  describe("Agent Status Management", function () {
    let tokenId;

    beforeEach(async function () {
      const tx = await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const receipt = await tx.wait();
      tokenId = 1;
    });

    it("Should pause an agent", async function () {
      await bep007.connect(user1).pause(tokenId);
      
      const state = await bep007.getState(tokenId);
      expect(state.status).to.equal(1); // Paused
    });

    it("Should unpause an agent", async function () {
      await bep007.connect(user1).pause(tokenId);
      await bep007.connect(user1).unpause(tokenId);
      
      const state = await bep007.getState(tokenId);
      expect(state.status).to.equal(0); // Active
    });

    it("Should terminate an agent", async function () {
      await bep007.connect(user1).terminate(tokenId);
      
      const state = await bep007.getState(tokenId);
      expect(state.status).to.equal(2); // Terminated
    });

    it("Should fail to pause if not owner", async function () {
      await expect(
        bep007.connect(user2).pause(tokenId)
      ).to.be.revertedWith("BEP007: caller is not agent owner");
    });

    it("Should fail to unpause if not paused", async function () {
      await expect(
        bep007.connect(user1).unpause(tokenId)
      ).to.be.revertedWith("BEP007: agent not paused");
    });

    it("Should fail to terminate if already terminated", async function () {
      await bep007.connect(user1).terminate(tokenId);
      
      await expect(
        bep007.connect(user1).terminate(tokenId)
      ).to.be.revertedWith("BEP007: agent already terminated");
    });
  });

  describe("Agent Withdrawal", function () {
    let tokenId;

    beforeEach(async function () {
      const tx = await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const receipt = await tx.wait();
      tokenId = 1;
      
      // Fund the agent
      await bep007.connect(user2).fundAgent(tokenId, { 
        value: ethers.utils.parseEther("1.0") 
      });
    });

    it("Should withdraw BNB from agent", async function () {
      const withdrawAmount = ethers.utils.parseEther("0.5");
      const initialBalance = await ethers.provider.getBalance(user1.address);
      
      const tx = await bep007.connect(user1).withdrawFromAgent(tokenId, withdrawAmount);
      const receipt = await tx.wait();
      
      // Calculate gas used
      const gasUsed = receipt.gasUsed.mul(receipt.effectiveGasPrice);
      
      // Check user balance increased (minus gas)
      const finalBalance = await ethers.provider.getBalance(user1.address);
      expect(finalBalance).to.be.closeTo(
        initialBalance.add(withdrawAmount).sub(gasUsed),
        ethers.utils.parseEther("0.01") // Allow for small rounding errors
      );
      
      // Check agent balance decreased
      const state = await bep007.getState(tokenId);
      expect(state.balance).to.equal(ethers.utils.parseEther("0.5"));
    });

    it("Should fail to withdraw more than available", async function () {
      const withdrawAmount = ethers.utils.parseEther("2.0"); // More than funded
      
      await expect(
        bep007.connect(user1).withdrawFromAgent(tokenId, withdrawAmount)
      ).to.be.revertedWith("BEP007: insufficient balance");
    });

    it("Should fail to withdraw if not owner", async function () {
      const withdrawAmount = ethers.utils.parseEther("0.5");
      
      await expect(
        bep007.connect(user2).withdrawFromAgent(tokenId, withdrawAmount)
      ).to.be.revertedWith("BEP007: caller is not agent owner");
    });
  });

  describe("Metadata Management", function () {
    let tokenId;

    beforeEach(async function () {
      const tx = await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const receipt = await tx.wait();
      tokenId = 1;
    });

    it("Should update agent metadata URI", async function () {
      await bep007.connect(user1).setAgentMetadataURI(tokenId, "ipfs://QmNewExample");
      
      expect(await bep007.tokenURI(tokenId)).to.equal("ipfs://QmNewExample");
    });

    it("Should fail to update metadata if not owner", async function () {
      await expect(
        bep007.connect(user2).setAgentMetadataURI(tokenId, "ipfs://QmNewExample")
      ).to.be.revertedWith("BEP007: caller is not agent owner");
    });
  });

  describe("Governance Functions", function () {
    it("Should set global pause state", async function () {
      await bep007.connect(owner).setGlobalPause(true);
      
      expect(await bep007.globalPause()).to.equal(true);
      
      await bep007.connect(owner).setGlobalPause(false);
      
      expect(await bep007.globalPause()).to.equal(false);
    });

    it("Should fail to set global pause if not governance", async function () {
      await expect(
        bep007.connect(user1).setGlobalPause(true)
      ).to.be.revertedWith("BEP007: caller is not governance");
    });

    it("Should update governance address", async function () {
      await bep007.connect(owner).setGovernance(user1.address);
      
      expect(await bep007.governance()).to.equal(user1.address);
    });

    it("Should fail to update governance if not current governance", async function () {
      await expect(
        bep007.connect(user1).setGovernance(user2.address)
      ).to.be.revertedWith("BEP007: caller is not governance");
    });
  });

  describe("Treasury Functions", function () {
    it("Should distribute fees correctly", async function () {
      const feeAmount = ethers.utils.parseEther("1.0");
      const treasuryFee = feeAmount.mul(1000).div(10000); // 10%
      const ownerFee = feeAmount.mul(2000).div(10000); // 20%
      
      const initialTreasuryBalance = await treasury.totalBnbBalance();
      const initialOwnerBalance = await ethers.provider.getBalance(user1.address);
      
      await treasury.connect(user2).distributeFees(user1.address, { value: feeAmount });
      
      // Check treasury balance increased by treasury fee
      const finalTreasuryBalance = await treasury.totalBnbBalance();
      expect(finalTreasuryBalance).to.equal(initialTreasuryBalance.add(treasuryFee));
      
      // Check owner balance increased by owner fee
      const finalOwnerBalance = await ethers.provider.getBalance(user1.address);
      expect(finalOwnerBalance).to.equal(initialOwnerBalance.add(ownerFee));
    });

    it("Should update fee percentages", async function () {
      await treasury.connect(owner).updateFeePercentages(500, 1500); // 5% treasury, 15% owner
      
      expect(await treasury.treasuryFeePercentage()).to.equal(500);
      expect(await treasury.ownerFeePercentage()).to.equal(1500);
    });

    it("Should fail to update fees if total exceeds 100%", async function () {
      await expect(
        treasury.connect(owner).updateFeePercentages(5000, 6000) // 50% + 60% = 110%
      ).to.be.revertedWith("BEP007Treasury: fee percentages exceed 100%");
    });
  });

  describe("Agent Factory", function () {
    it("Should register agent templates", async function () {
      await agentFactory.registerTemplate("DeFi", defiAgent.address);
      await agentFactory.registerTemplate("Game", gameAgent.address);
      await agentFactory.registerTemplate("DAO", daoAgent.address);
      
      expect(await agentFactory.getTemplate("DeFi")).to.equal(defiAgent.address);
      expect(await agentFactory.getTemplate("Game")).to.equal(gameAgent.address);
      expect(await agentFactory.getTemplate("DAO")).to.equal(daoAgent.address);
    });

    it("Should create agent from template", async function () {
      await agentFactory.registerTemplate("DeFi", defiAgent.address);
      
      await agentFactory.connect(user1).createAgentFromTemplate(
        "DeFi",
        "ipfs://QmExample",
        { value: ethers.utils.parseEther("0.1") } // Creation fee
      );
      
      // Check that user1 owns token #1
      expect(await bep007.ownerOf(1)).to.equal(user1.address);
      
      // Check that the logic address is the DeFi template
      const state = await bep007.getState(1);
      expect(state.logicAddress).to.equal(defiAgent.address);
    });

    it("Should fail to create agent with unregistered template", async function () {
      await expect(
        agentFactory.connect(user1).createAgentFromTemplate(
          "Unregistered",
          "ipfs://QmExample",
          { value: ethers.utils.parseEther("0.1") }
        )
      ).to.be.revertedWith("AgentFactory: template not registered");
    });
  });

  describe("Circuit Breaker", function () {
    it("Should pause all agents in emergency", async function () {
      // Create an agent
      await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      
      // Set circuit breaker as emergency admin
      await circuitBreaker.setTargetContract(bep007.address);
      await circuitBreaker.setEmergencyAdmin(owner.address);
      
      // Trigger emergency pause
      await circuitBreaker.connect(owner).triggerEmergencyPause();
      
      // Check global pause is active
      expect(await bep007.globalPause()).to.equal(true);
    });

    it("Should resume operations after emergency", async function () {
      // Set circuit breaker as emergency admin
      await circuitBreaker.setTargetContract(bep007.address);
      await circuitBreaker.setEmergencyAdmin(owner.address);
      
      // Trigger emergency pause
      await circuitBreaker.connect(owner).triggerEmergencyPause();
      
      // Resume operations
      await circuitBreaker.connect(owner).resumeOperations();
      
      // Check global pause is inactive
      expect(await bep007.globalPause()).to.equal(false);
    });

    it("Should fail to trigger emergency if not admin", async function () {
      await circuitBreaker.setTargetContract(bep007.address);
      await circuitBreaker.setEmergencyAdmin(owner.address);
      
      await expect(
        circuitBreaker.connect(user1).triggerEmergencyPause()
      ).to.be.revertedWith("CircuitBreaker: not emergency admin");
    });
  });

  describe("Integration Tests", function () {
    it("Should handle full agent lifecycle", async function () {
      // 1. Create agent
      await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const tokenId = 1;
      
      // 2. Fund agent
      await bep007.connect(user2).fundAgent(tokenId, { 
        value: ethers.utils.parseEther("1.0") 
      });
      
      // 3. Update logic
      await bep007.connect(user1).setLogicAddress(tokenId, gameAgent.address);
      
      // 4. Update metadata
      await bep007.connect(user1).setAgentMetadataURI(tokenId, "ipfs://QmNewExample");
      
      // 5. Pause agent
      await bep007.connect(user1).pause(tokenId);
      
      // 6. Unpause agent
      await bep007.connect(user1).unpause(tokenId);
      
      // 7. Withdraw funds
      await bep007.connect(user1).withdrawFromAgent(
        tokenId, 
        ethers.utils.parseEther("0.5")
      );
      
      // 8. Terminate agent
      await bep007.connect(user1).terminate(tokenId);
      
      // 9. Verify final state
      const state = await bep007.getState(tokenId);
      expect(state.status).to.equal(2); // Terminated
      expect(state.balance).to.equal(0); // All funds returned
      expect(state.logicAddress).to.equal(gameAgent.address);
    });

    it("Should handle agent transfer correctly", async function () {
      // 1. Create agent
      await bep007.createAgent(
        user1.address,
        defiAgent.address,
        "ipfs://QmExample"
      );
      const tokenId = 1;
      
      // 2. Transfer agent to user2
      await bep007.connect(user1).transferFrom(user1.address, user2.address, tokenId);
      
      // 3. Verify ownership changed
      expect(await bep007.ownerOf(tokenId)).to.equal(user2.address);
      
      // 4. Verify state updated
      const state = await bep007.getState(tokenId);
      expect(state.owner).to.equal(user2.address);
      
      // 5. Verify only new owner can control agent
      await expect(
        bep007.connect(user1).pause(tokenId)
      ).to.be.revertedWith("BEP007: caller is not agent owner");
      
      // 6. New owner can control agent
      await bep007.connect(user2).pause(tokenId);
      
      const updatedState = await bep007.getState(tokenId);
      expect(updatedState.status).to.equal(1); // Paused
    });
  });
});
