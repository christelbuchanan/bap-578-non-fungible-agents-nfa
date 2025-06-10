/**
 * Example: Integrating Merkle Tree Learning with BEP007 Agents
 * This demonstrates how developers can use the enhanced BEP007 standard
 * with optional learning capabilities from day 1.
 */

const { ethers } = require("ethers");

// Example learning tree structure for off-chain storage
const createLearningTree = (agentData) => {
  return {
    root: "0x...", // Calculated Merkle root
    branches: {
      codingStyle: {
        indentation: agentData.preferences?.indentation || "2-spaces",
        naming: agentData.preferences?.naming || "camelCase", 
        patterns: agentData.patterns || ["functional", "modular"],
        confidence: agentData.confidence || 0.5
      },
      userPreferences: {
        frameworks: agentData.frameworks || ["React", "Vue"],
        languages: agentData.languages || ["TypeScript", "Solidity"],
        testingStyle: agentData.testing || "jest-focused"
      },
      interactions: {
        totalSessions: agentData.sessions || 0,
        avgSessionLength: agentData.avgSession || "0min",
        successfulTasks: agentData.successful || 0,
        learningVelocity: agentData.velocity || 0.0
      }
    },
    metadata: {
      version: "1.0.0",
      lastUpdated: new Date().toISOString(),
      agentId: agentData.tokenId
    }
  };
};

// Example: Creating an agent with learning enabled from day 1
async function createLearningAgent(agentFactory, merkleTreeLearning, owner) {
  console.log("🚀 Creating agent with learning enabled...");
  
  // 1. Create initial learning tree
  const initialLearningData = {
    tokenId: null, // Will be set after creation
    preferences: { indentation: "2-spaces", naming: "camelCase" },
    patterns: ["functional", "modular"],
    confidence: 0.1 // Starting confidence
  };
  
  const learningTree = createLearningTree(initialLearningData);
  const initialRoot = ethers.utils.keccak256(
    ethers.utils.toUtf8Bytes(JSON.stringify(learningTree.branches))
  );
  
  // 2. Create enhanced metadata with learning enabled
  const enhancedMetadata = {
    persona: JSON.stringify({
      traits: ["analytical", "helpful", "adaptive"],
      style: "professional",
      tone: "friendly"
    }),
    imprint: "AI coding assistant specialized in blockchain development",
    voiceHash: "bafkreigh2akiscaild...", // IPFS hash for voice profile
    animationURI: "ipfs://Qm.../agent_avatar.mp4",
    vaultURI: "ipfs://Qm.../agent_vault.json",
    vaultHash: ethers.utils.keccak256(ethers.utils.toUtf8Bytes("vault_content")),
    // Learning fields
    learningEnabled: true,
    learningModule: merkleTreeLearning.address,
    learningTreeRoot: initialRoot,
    learningVersion: 1
  };
  
  // 3. Create the agent
  const tx = await agentFactory.createAgent(
    "Learning Code Agent",
    "LCA",
    "0x1234567890123456789012345678901234567890", // Logic contract address
    "ipfs://metadata-uri",
    enhancedMetadata
  );
  
  const receipt = await tx.wait();
  const agentCreatedEvent = receipt.events.find(e => e.event === "AgentCreated");
  const agentAddress = agentCreatedEvent.args.agent;
  const tokenId = 1; // First token
  
  console.log(`✅ Agent created at: ${agentAddress}`);
  console.log(`🧠 Learning enabled with token ID: ${tokenId}`);
  
  return { agentAddress, tokenId, learningTree };
}

// Example: Creating a simple agent without learning (backward compatibility)
async function createSimpleAgent(agentFactory, owner) {
  console.log("📝 Creating simple agent (no learning)...");
  
  // Use the simple createAgent function - learning disabled by default
  const tx = await agentFactory.createAgent(
    "Simple Code Agent", 
    "SCA",
    "0x1234567890123456789012345678901234567890", // Logic contract address
    "ipfs://simple-metadata-uri"
  );
  
  const receipt = await tx.wait();
  const agentCreatedEvent = receipt.events.find(e => e.event === "AgentCreated");
  const agentAddress = agentCreatedEvent.args.agent;
  
  console.log(`✅ Simple agent created at: ${agentAddress}`);
  console.log(`📚 JSON light memory enabled by default`);
  
  return agentAddress;
}

// Example: Upgrading a simple agent to use learning
async function upgradToLearning(bep007Enhanced, merkleTreeLearning, tokenId, owner) {
  console.log("🔄 Upgrading agent to enable learning...");
  
  // 1. Create initial learning tree
  const learningTree = createLearningTree({ tokenId });
  const initialRoot = ethers.utils.keccak256(
    ethers.utils.toUtf8Bytes(JSON.stringify(learningTree.branches))
  );
  
  // 2. Enable learning on existing agent
  const tx = await bep007Enhanced.enableLearning(
    tokenId,
    merkleTreeLearning.address,
    initialRoot
  );
  
  await tx.wait();
  console.log(`🧠 Learning enabled for token ID: ${tokenId}`);
  
  return learningTree;
}

// Example: Recording interactions and updating learning
async function recordLearningInteraction(bep007Enhanced, tokenId, interactionType, success) {
  console.log(`📊 Recording interaction: ${interactionType} (${success ? 'success' : 'failure'})`);
  
  const tx = await bep007Enhanced.recordInteraction(
    tokenId,
    interactionType,
    success
  );
  
  await tx.wait();
  console.log(`✅ Interaction recorded`);
}

// Example: Verifying learning claims
async function verifyLearningClaim(bep007Enhanced, tokenId, claim, proof) {
  console.log("🔍 Verifying learning claim...");
  
  const isValid = await bep007Enhanced.verifyLearningClaim(
    tokenId,
    claim,
    proof
  );
  
  console.log(`${isValid ? '✅' : '❌'} Claim verification: ${isValid}`);
  return isValid;
}

// Example: Getting learning metrics
async function getLearningMetrics(bep007Enhanced, tokenId) {
  console.log("📈 Fetching learning metrics...");
  
  const { enabled, moduleAddress, metrics } = await bep007Enhanced.getLearningInfo(tokenId);
  
  if (enabled) {
    console.log(`🧠 Learning Module: ${moduleAddress}`);
    console.log(`📊 Total Interactions: ${metrics.totalInteractions}`);
    console.log(`🎯 Learning Events: ${metrics.learningEvents}`);
    console.log(`⚡ Learning Velocity: ${ethers.utils.formatUnits(metrics.learningVelocity, 18)}`);
    console.log(`🎖️ Confidence Score: ${ethers.utils.formatUnits(metrics.confidenceScore, 18)}`);
  } else {
    console.log("📚 Agent using JSON light memory (learning disabled)");
  }
  
  return { enabled, moduleAddress, metrics };
}

// Main example function
async function main() {
  // Setup contracts (assuming they're deployed)
  const [owner] = await ethers.getSigners();
  const agentFactory = await ethers.getContractAt("AgentFactory", "0x...");
  const bep007Enhanced = await ethers.getContractAt("BEP007Enhanced", "0x...");
  const merkleTreeLearning = await ethers.getContractAt("MerkleTreeLearning", "0x...");
  
  console.log("🌟 BEP007 Enhanced Learning Demo");
  console.log("================================");
  
  // Scenario 1: Savvy developer creates learning agent from day 1
  const { agentAddress: learningAgent, tokenId: learningTokenId } = await createLearningAgent(
    agentFactory, 
    merkleTreeLearning, 
    owner
  );
  
  // Scenario 2: Regular developer creates simple agent
  const simpleAgent = await createSimpleAgent(agentFactory, owner);
  
  // Scenario 3: Simple agent owner decides to upgrade to learning
  await upgradToLearning(bep007Enhanced, merkleTreeLearning, 2, owner); // Token ID 2
  
  // Scenario 4: Record some interactions for the learning agent
  await recordLearningInteraction(bep007Enhanced, learningTokenId, "code_generation", true);
  await recordLearningInteraction(bep007Enhanced, learningTokenId, "bug_fixing", true);
  await recordLearningInteraction(bep007Enhanced, learningTokenId, "optimization", false);
  
  // Scenario 5: Check learning progress
  await getLearningMetrics(bep007Enhanced, learningTokenId);
  
  console.log("\n🎉 Demo completed! Both simple and learning agents coexist perfectly.");
}

module.exports = {
  createLearningTree,
  createLearningAgent,
  createSimpleAgent,
  upgradToLearning,
  recordLearningInteraction,
  verifyLearningClaim,
  getLearningMetrics,
  main
};
