const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Deploying BEP007 contracts to BNB Chain...");

  // Get the contract factories
  const BEP007 = await ethers.getContractFactory("BEP007");
  const AgentFactory = await ethers.getContractFactory("AgentFactory");
  const BEP007Governance = await ethers.getContractFactory("BEP007Governance");
  const MemoryModuleRegistry = await ethers.getContractFactory("MemoryModuleRegistry");
  const VaultPermissionManager = await ethers.getContractFactory("VaultPermissionManager");
  const CircuitBreaker = await ethers.getContractFactory("CircuitBreaker");
  const BEP007Treasury = await ethers.getContractFactory("BEP007Treasury");

  // Deploy the CircuitBreaker first (needed for other contracts)
  console.log("Deploying CircuitBreaker...");
  const circuitBreaker = await CircuitBreaker.deploy();
  await circuitBreaker.deployed();
  console.log("CircuitBreaker deployed to:", circuitBreaker.address);

  // Deploy the BEP007 token contract as upgradeable
  console.log("Deploying BEP007...");
  const bep007 = await upgrades.deployProxy(BEP007, [
    "BEP007 Non-Fungible Agent", // name
    "NFA", // symbol
    circuitBreaker.address // circuit breaker address
  ]);
  await bep007.deployed();
  console.log("BEP007 deployed to:", bep007.address);

  // Deploy the AgentFactory
  console.log("Deploying AgentFactory...");
  const agentFactory = await AgentFactory.deploy(bep007.address);
  await agentFactory.deployed();
  console.log("AgentFactory deployed to:", agentFactory.address);

  // Deploy the MemoryModuleRegistry
  console.log("Deploying MemoryModuleRegistry...");
  const memoryModuleRegistry = await MemoryModuleRegistry.deploy(bep007.address);
  await memoryModuleRegistry.deployed();
  console.log("MemoryModuleRegistry deployed to:", memoryModuleRegistry.address);

  // Deploy the VaultPermissionManager
  console.log("Deploying VaultPermissionManager...");
  const vaultPermissionManager = await VaultPermissionManager.deploy(bep007.address);
  await vaultPermissionManager.deployed();
  console.log("VaultPermissionManager deployed to:", vaultPermissionManager.address);

  // Deploy the BEP007Treasury
  console.log("Deploying BEP007Treasury...");
  const bep007Treasury = await BEP007Treasury.deploy();
  await bep007Treasury.deployed();
  console.log("BEP007Treasury deployed to:", bep007Treasury.address);

  // Deploy the BEP007Governance
  console.log("Deploying BEP007Governance...");
  const bep007Governance = await BEP007Governance.deploy(
    bep007.address,
    circuitBreaker.address,
    bep007Treasury.address
  );
  await bep007Governance.deployed();
  console.log("BEP007Governance deployed to:", bep007Governance.address);

  // Set up the governance as the owner of the circuit breaker
  console.log("Setting up governance permissions...");
  await circuitBreaker.transferOwnership(bep007Governance.address);
  console.log("CircuitBreaker ownership transferred to governance");

  // Deploy template contracts
  console.log("Deploying template contracts...");
  
  // DeFi Agent template
  const DeFiAgent = await ethers.getContractFactory("DeFiAgent");
  const defiAgent = await DeFiAgent.deploy();
  await defiAgent.deployed();
  console.log("DeFiAgent template deployed to:", defiAgent.address);
  
  // Game Agent template
  const GameAgent = await ethers.getContractFactory("GameAgent");
  const gameAgent = await GameAgent.deploy();
  await gameAgent.deployed();
  console.log("GameAgent template deployed to:", gameAgent.address);
  
  // DAO Agent template
  const DAOAgent = await ethers.getContractFactory("DAOAgent");
  const daoAgent = await DAOAgent.deploy();
  await daoAgent.deployed();
  console.log("DAOAgent template deployed to:", daoAgent.address);

  // Approve templates in the AgentFactory
  console.log("Approving templates in AgentFactory...");
  await agentFactory.approveTemplate(defiAgent.address, "DeFi", "1.0.0");
  await agentFactory.approveTemplate(gameAgent.address, "Game", "1.0.0");
  await agentFactory.approveTemplate(daoAgent.address, "DAO", "1.0.0");
  console.log("Templates approved");

  console.log("Deployment complete!");
  console.log("----------------------------------------------------");
  console.log("BEP007 Contracts Deployment Summary:");
  console.log("----------------------------------------------------");
  console.log("BEP007:", bep007.address);
  console.log("AgentFactory:", agentFactory.address);
  console.log("BEP007Governance:", bep007Governance.address);
  console.log("MemoryModuleRegistry:", memoryModuleRegistry.address);
  console.log("VaultPermissionManager:", vaultPermissionManager.address);
  console.log("CircuitBreaker:", circuitBreaker.address);
  console.log("BEP007Treasury:", bep007Treasury.address);
  console.log("----------------------------------------------------");
  console.log("Template Contracts:");
  console.log("----------------------------------------------------");
  console.log("DeFiAgent:", defiAgent.address);
  console.log("GameAgent:", gameAgent.address);
  console.log("DAOAgent:", daoAgent.address);
  console.log("----------------------------------------------------");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
