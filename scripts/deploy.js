const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying BEP-007 Non-Fungible Agent contracts...");

  // Get the contract factories
  const CircuitBreaker = await ethers.getContractFactory("CircuitBreaker");
  const BEP007Treasury = await ethers.getContractFactory("BEP007Treasury");
  const BEP007Governance = await ethers.getContractFactory("BEP007Governance");
  const ImprintModuleRegistry = await ethers.getContractFactory("ImprintModuleRegistry");
  const VaultPermissionManager = await ethers.getContractFactory("VaultPermissionManager");
  const AgentFactory = await ethers.getContractFactory("AgentFactory");

  // Deploy CircuitBreaker first
  console.log("Deploying CircuitBreaker...");
  const circuitBreaker = await CircuitBreaker.deploy();
  await circuitBreaker.deployed();
  console.log("CircuitBreaker deployed to:", circuitBreaker.address);

  // Deploy Treasury
  console.log("Deploying BEP007Treasury...");
  const treasury = await BEP007Treasury.deploy();
  await treasury.deployed();
  console.log("BEP007Treasury deployed to:", treasury.address);

  // Deploy Governance
  console.log("Deploying BEP007Governance...");
  const governance = await BEP007Governance.deploy(circuitBreaker.address, treasury.address);
  await governance.deployed();
  console.log("BEP007Governance deployed to:", governance.address);

  // Set governance as admin in CircuitBreaker
  console.log("Setting governance as admin in CircuitBreaker...");
  await circuitBreaker.setGovernance(governance.address);
  console.log("Governance set as admin in CircuitBreaker");

  // Deploy ImprintModuleRegistry
  console.log("Deploying ImprintModuleRegistry...");
  const memoryRegistry = await ImprintModuleRegistry.deploy(circuitBreaker.address);
  await memoryRegistry.deployed();
  console.log("ImprintModuleRegistry deployed to:", memoryRegistry.address);

  // Deploy VaultPermissionManager
  console.log("Deploying VaultPermissionManager...");
  const vaultManager = await VaultPermissionManager.deploy(circuitBreaker.address);
  await vaultManager.deployed();
  console.log("VaultPermissionManager deployed to:", vaultManager.address);

  // Deploy AgentFactory
  console.log("Deploying AgentFactory...");
  const agentFactory = await AgentFactory.deploy(
    circuitBreaker.address,
    memoryRegistry.address,
    vaultManager.address,
    treasury.address
  );
  await agentFactory.deployed();
  console.log("AgentFactory deployed to:", agentFactory.address);

  // Deploy template contracts
  console.log("Deploying template contracts...");
  
  const DeFiAgent = await ethers.getContractFactory("DeFiAgent");
  const defiAgent = await DeFiAgent.deploy();
  await defiAgent.deployed();
  console.log("DeFiAgent template deployed to:", defiAgent.address);
  
  const GameAgent = await ethers.getContractFactory("GameAgent");
  const gameAgent = await GameAgent.deploy();
  await gameAgent.deployed();
  console.log("GameAgent template deployed to:", gameAgent.address);
  
  const DAOAgent = await ethers.getContractFactory("DAOAgent");
  const daoAgent = await DAOAgent.deploy();
  await daoAgent.deployed();
  console.log("DAOAgent template deployed to:", daoAgent.address);

  // Approve templates in AgentFactory
  console.log("Approving templates in AgentFactory...");
  await agentFactory.approveTemplate(defiAgent.address, "DeFi", "1.0.0");
  await agentFactory.approveTemplate(gameAgent.address, "Game", "1.0.0");
  await agentFactory.approveTemplate(daoAgent.address, "DAO", "1.0.0");
  console.log("Templates approved in AgentFactory");

  console.log("Deployment complete!");
  console.log("----------------------------------------------------");
  console.log("Contract Addresses:");
  console.log("CircuitBreaker:", circuitBreaker.address);
  console.log("BEP007Treasury:", treasury.address);
  console.log("BEP007Governance:", governance.address);
  console.log("ImprintModuleRegistry:", memoryRegistry.address);
  console.log("VaultPermissionManager:", vaultManager.address);
  console.log("AgentFactory:", agentFactory.address);
  console.log("DeFiAgent Template:", defiAgent.address);
  console.log("GameAgent Template:", gameAgent.address);
  console.log("DAOAgent Template:", daoAgent.address);
  console.log("----------------------------------------------------");
  console.log("Update your .env file with these addresses");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
