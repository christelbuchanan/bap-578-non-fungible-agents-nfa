const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Deploying BEP-007 Non-Fungible Agent contracts...");

  // Deploy the timelock controller for governance
  const TimelockController = await ethers.getContractFactory("TimelockController");
  const minDelay = 172800; // 2 days in seconds
  const proposers = []; // Will be set after governance deployment
  const executors = []; // Will be set after governance deployment
  const admin = ethers.constants.AddressZero; // Zero address means no admin
  const timelock = await TimelockController.deploy(minDelay, proposers, executors, admin);
  await timelock.deployed();
  console.log("TimelockController deployed to:", timelock.address);

  // Deploy the BEP007 implementation
  const BEP007 = await ethers.getContractFactory("BEP007");
  const bep007Implementation = await BEP007.deploy();
  await bep007Implementation.deployed();
  console.log("BEP007 implementation deployed to:", bep007Implementation.address);

  // Deploy the governance contract
  const BEP007Governance = await ethers.getContractFactory("BEP007Governance");
  const votingDelay = 13091; // ~2 days in blocks
  const votingPeriod = 45818; // ~7 days in blocks
  const proposalThreshold = ethers.utils.parseEther("1000"); // 1000 BNB
  const governance = await upgrades.deployProxy(
    BEP007Governance,
    [
      "BEP007 Governance",
      bep007Implementation.address,
      timelock.address,
      votingDelay,
      votingPeriod,
      proposalThreshold
    ],
    { initializer: "initialize" }
  );
  await governance.deployed();
  console.log("BEP007Governance deployed to:", governance.address);

  // Update the timelock's proposers and executors
  await timelock.grantRole(await timelock.PROPOSER_ROLE(), governance.address);
  await timelock.grantRole(await timelock.EXECUTOR_ROLE(), governance.address);
  console.log("Updated TimelockController roles");

  // Deploy the treasury
  const BEP007Treasury = await ethers.getContractFactory("BEP007Treasury");
  const treasuryFeePercentage = 1000; // 10%
  const ownerFeePercentage = 2000; // 20%
  const treasury = await upgrades.deployProxy(
    BEP007Treasury,
    [governance.address, treasuryFeePercentage, ownerFeePercentage],
    { initializer: "initialize" }
  );
  await treasury.deployed();
  console.log("BEP007Treasury deployed to:", treasury.address);

  // Set the treasury address in the governance contract
  await governance.setTreasury(treasury.address);
  console.log("Set treasury address in governance");

  // Deploy the agent factory
  const AgentFactory = await ethers.getContractFactory("AgentFactory");
  const agentFactory = await upgrades.deployProxy(
    AgentFactory,
    [bep007Implementation.address, governance.address],
    { initializer: "initialize" }
  );
  await agentFactory.deployed();
  console.log("AgentFactory deployed to:", agentFactory.address);

  // Set the agent factory address in the governance contract
  await governance.setAgentFactory(agentFactory.address);
  console.log("Set agent factory address in governance");

  // Deploy the circuit breaker
  const CircuitBreaker = await ethers.getContractFactory("CircuitBreaker");
  const [deployer] = await ethers.getSigners();
  const emergencyMultiSig = deployer.address; // In production, this should be a multi-sig wallet
  const circuitBreaker = await upgrades.deployProxy(
    CircuitBreaker,
    [governance.address, emergencyMultiSig],
    { initializer: "initialize" }
  );
  await circuitBreaker.deployed();
  console.log("CircuitBreaker deployed to:", circuitBreaker.address);

  // Deploy the template contracts
  console.log("Deploying agent templates...");

  // Deploy the DeFi agent template
  const DeFiAgent = await ethers.getContractFactory("DeFiAgent");
  const mockPriceOracle = "0x9326BFA02ADD2366b30bacB125260Af641031331"; // Chainlink ETH/USD price feed on BSC testnet
  const mockDexRouter = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"; // PancakeSwap router on BSC testnet
  const defiAgent = await DeFiAgent.deploy(
    bep007Implementation.address,
    mockDexRouter,
    treasury.address,
    mockPriceOracle
  );
  await defiAgent.deployed();
  console.log("DeFiAgent template deployed to:", defiAgent.address);

  // Approve the DeFi agent template in the factory
  await agentFactory.approveTemplate(defiAgent.address, "DeFi", "1.0.0");
  console.log("Approved DeFiAgent template in factory");

  // Deploy the Game agent template
  const GameAgent = await ethers.getContractFactory("GameAgent");
  const mockGameContract = deployer.address; // In production, this should be the game contract
  const gameAgent = await GameAgent.deploy(
    bep007Implementation.address,
    mockGameContract
  );
  await gameAgent.deployed();
  console.log("GameAgent template deployed to:", gameAgent.address);

  // Approve the Game agent template in the factory
  await agentFactory.approveTemplate(gameAgent.address, "Game", "1.0.0");
  console.log("Approved GameAgent template in factory");

  // Deploy the DAO agent template
  const DAOAgent = await ethers.getContractFactory("DAOAgent");
  const mockDaoContract = deployer.address; // In production, this should be the DAO contract
  const daoAgent = await DAOAgent.deploy(
    bep007Implementation.address,
    mockDaoContract
  );
  await daoAgent.deployed();
  console.log("DAOAgent template deployed to:", daoAgent.address);

  // Approve the DAO agent template in the factory
  await agentFactory.approveTemplate(daoAgent.address, "DAO", "1.0.0");
  console.log("Approved DAOAgent template in factory");

  console.log("BEP-007 Non-Fungible Agent deployment complete!");
  console.log("----------------------------------------------------");
  console.log("BEP007 Implementation:", bep007Implementation.address);
  console.log("BEP007Governance:", governance.address);
  console.log("TimelockController:", timelock.address);
  console.log("BEP007Treasury:", treasury.address);
  console.log("AgentFactory:", agentFactory.address);
  console.log("CircuitBreaker:", circuitBreaker.address);
  console.log("Templates:");
  console.log("  - DeFiAgent:", defiAgent.address);
  console.log("  - GameAgent:", gameAgent.address);
  console.log("  - DAOAgent:", daoAgent.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
