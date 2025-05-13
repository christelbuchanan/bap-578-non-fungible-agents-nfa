# BEP-007 Architecture Guide

This document provides an overview of the BEP-007 Non-Fungible Agent (NFA) architecture, explaining the key components and their interactions. It serves as a guide for developers working with the BEP-007 standard.

## Table of Contents

1. [Smart Contract Architecture](#smart-contract-architecture)
2. [Core Components](#core-components)
3. [Extended Metadata Schema](#extended-metadata-schema)
4. [Memory Module System](#memory-module-system)
5. [Vault Permission System](#vault-permission-system)
6. [Agent Templates](#agent-templates)
7. [Security Mechanisms](#security-mechanisms)
8. [Integration Patterns](#integration-patterns)

## Smart Contract Architecture

The BEP-007 token standard builds upon ERC-721 to introduce a composable framework for intelligent, evolving agents. The architecture has been designed to accommodate both static NFT functionality and dynamic extensions critical for agent behavior, media, and memory.

### Design Principles

1. **ERC-721 Compatibility**: BEP-007 maintains compatibility by inheriting core functionality: unique token IDs, safe transfers, ownership tracking, and metadata URI referencing.

2. **Modularity**: The system is designed with separate components that can be upgraded or replaced independently.

3. **Hybrid Storage**: Essential agent identity attributes are committed on-chain to optimize gas usage. Full persona trees, voice samples, and extended memory reside off-chain in a vault, referenced by URI and validated using hash checks.

4. **Security First**: Granular access control and cryptographic verification ensure that only authorized parties can modify agent data or access sensitive information.

5. **Forward Compatibility**: The standard is designed to support future extensions and upgrades without breaking existing functionality.

## Core Components

### BEP007.sol

The main contract that implements the Non-Fungible Agent token standard. It extends ERC-721 with agent-specific functionality.

Key features:
- Agent creation with extended metadata
- Action execution via delegatecall
- Logic upgradeability
- Agent state management
- Circuit breaker for emergency pauses

```solidity
// Example: Creating an agent with extended metadata
function createAgent(
    address to, 
    address logicAddress, 
    string memory metadataURI,
    AgentMetadata memory extendedMetadata
) external returns (uint256 tokenId);

// Example: Executing an agent action
function executeAction(
    uint256 tokenId, 
    bytes calldata data
) external nonReentrant whenAgentActive(tokenId);
```

### AgentFactory.sol

Factory contract for deploying new agent tokens with customizable templates.

Key features:
- Template management (approval, revocation)
- Agent creation with consistent initialization
- Version tracking for templates

```solidity
// Example: Creating an agent through the factory
function createAgent(
    string memory name,
    string memory symbol,
    address logicAddress,
    string memory metadataURI,
    IBEP007.AgentMetadata memory extendedMetadata
) external returns (address agent);
```

### MemoryModuleRegistry.sol

Registry for agent memory modules that allows agents to register approved external memory sources.

Key features:
- Cryptographic verification for module registration
- Module approval and revocation
- Metadata management for modules

```solidity
// Example: Registering a memory module
function registerModule(
    uint256 tokenId,
    address moduleAddress,
    string memory metadata,
    bytes memory signature
) external nonReentrant;
```

### VaultPermissionManager.sol

Manages permissions for agent vaults, handling cryptographic key-pair delegation for vault access.

Key features:
- Time-based access delegation
- Cryptographic verification for access requests
- Access revocation

```solidity
// Example: Delegating vault access
function delegateAccess(
    uint256 tokenId,
    address delegate,
    uint256 expiryTime,
    bytes memory signature
) external nonReentrant;
```

### CircuitBreaker.sol

Emergency shutdown mechanism with global and targeted pause capabilities.

Key features:
- Global pause for system-wide emergencies
- Contract-specific pauses for targeted intervention
- Multi-level authorization (governance and emergency multi-sig)

## Extended Metadata Schema

BEP-007 extends the standard ERC-721 metadata with additional fields specifically designed for agent functionality:

```solidity
struct AgentMetadata {
    string persona;       // JSON-encoded string for character traits, style, tone
    string memory;        // Short summary string for agent's role/purpose
    string voiceHash;     // Reference ID to stored audio profile
    string animationURI;  // URI to video or animation file
    string vaultURI;      // URI to the agent's vault (extended data storage)
    bytes32 vaultHash;    // Hash of the vault contents for verification
}
```

### Metadata Fields Explained

- **persona**: A JSON-encoded string representing character traits, style, tone, and behavioral intent. This defines how the agent should behave and interact.

- **memory**: A short summary string describing the agent's default role or purpose. This provides context for the agent's actions.

- **voiceHash**: A reference ID to a stored audio profile (e.g., via IPFS or Arweave). This allows agents to have consistent voice characteristics.

- **animationURI**: A URI to a video or Lottie-compatible animation file. This provides visual representation for the agent.

- **vaultURI**: A URI to the agent's vault, which contains extended data that would be too expensive to store on-chain.

- **vaultHash**: A hash of the vault contents for verification. This ensures the integrity of off-chain data.

## Memory Module System

The Memory Module system allows agents to register and manage external memory sources, providing a way to extend an agent's capabilities without modifying the core contract.

### Memory Module Schema

Memory modules are structured as JSON documents that include structured memory layers, custom prompts, and modular behaviors:

```json
{
  "context_id": "nfa007-memory-001",
  "owner": "0xUserWalletAddress",
  "created": "2025-05-12T10:00:00Z",
  "persona": "Strategic crypto analyst",
  "memory_slots": [
    {
      "type": "alert_keywords",
      "data": ["FUD", "rugpull", "hack", "$BNB", "scam"]
    },
    {
      "type": "watchlist",
      "data": ["CZ", "Binance", "Tether", "SEC"]
    },
    {
      "type": "behavior_rules",
      "data": [
        "If sentiment drops >10% in 24h, alert user",
        "If wallet activity spikes, summarize top 5 tokens"
      ]
    }
  ],
  "last_updated": "2025-05-12T11:00:00Z",
  "signed": "0xAgentSig"
}
```

### Registration Process

1. The agent owner creates a memory module with the desired functionality
2. The owner signs the module data with their private key
3. The module is registered with the MemoryModuleRegistry contract
4. The registry verifies the signature and stores the module reference
5. The agent can now access and use the registered module

## Vault Permission System

The Vault Permission System provides secure access control for off-chain data vaults, allowing agent owners to delegate access to specific addresses for limited time periods.

### Key Features

- **Owner Control**: Only the agent owner can delegate or revoke access
- **Time-Based Delegation**: Access can be granted for specific time periods
- **Cryptographic Verification**: All access requests are verified using cryptographic signatures
- **Revocation**: Access can be revoked at any time by the owner

### Delegation Process

1. The agent owner decides to delegate access to a specific address
2. The owner signs a message containing the token ID, delegate address, and expiry time
3. The delegation is registered with the VaultPermissionManager contract
4. The manager verifies the signature and grants access
5. The delegate can access the vault until the expiry time or until access is revoked

## Agent Templates

BEP-007 includes a template system for creating specialized agent types. These templates provide pre-configured logic for specific use cases.

### Available Templates

- **DeFiAgent.sol**: Template for DeFi-focused agents (trading, liquidity provision)
- **GameAgent.sol**: Template for gaming-focused agents (NPCs, item management)
- **DAOAgent.sol**: Template for DAO-focused agents (voting, proposal execution)

### Template Usage

Templates are approved by the governance and can be used through the AgentFactory:

```javascript
// Get the latest DeFi template
const defiTemplate = await agentFactory.getLatestTemplate("DeFi");

// Create an agent using the template
const tx = await agentFactory.createAgent(
  "My DeFi Agent",
  "MDA",
  defiTemplate,
  "ipfs://metadata-uri",
  extendedMetadata
);
```

## Security Mechanisms

BEP-007 implements several security mechanisms to protect agents and their owners:

### Circuit Breaker

The protocol includes a dual-layer pause mechanism:
- Global pause for system-wide emergencies
- Contract-specific pauses for targeted intervention
- Controlled by both governance and emergency multi-sig for rapid response

### Reentrancy Protection

All fund-handling functions are protected against reentrancy attacks using OpenZeppelin's ReentrancyGuard.

### Gas Limits

Delegatecall operations have gas limits to prevent out-of-gas attacks:

```solidity
uint256 public constant MAX_GAS_FOR_DELEGATECALL = 3000000;

// Execute the action via delegatecall with gas limit
(bool success, bytes memory result) = agentState.logicAddress.delegatecall{gas: MAX_GAS_FOR_DELEGATECALL}(data);
```

### Access Control

Strict access control for sensitive operations:

```solidity
modifier onlyAgentOwner(uint256 tokenId) {
    require(ownerOf(tokenId) == msg.sender, "BEP007: caller is not agent owner");
    _;
}

modifier onlyGovernance() {
    require(msg.sender == governance, "BEP007: caller is not governance");
    _;
}
```

### Cryptographic Verification

Signature-based verification for memory module registration and vault access:

```solidity
// Verify the signature
bytes32 messageHash = keccak256(abi.encodePacked(tokenId, moduleAddress, metadata));
bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
address signer = ethSignedMessageHash.recover(signature);

require(signer == owner, "MemoryModuleRegistry: invalid signature");
```

## Integration Patterns

### Creating and Managing Agents

```javascript
// 1. Deploy a logic contract
const DeFiAgent = await ethers.getContractFactory("DeFiAgent");
const defiAgent = await DeFiAgent.deploy();
await defiAgent.deployed();

// 2. Create extended metadata
const extendedMetadata = {
  persona: "Strategic crypto analyst",
  memory: "crypto intelligence, FUD scanner",
  voiceHash: "bafkreigh2akiscaildc...",
  animationURI: "ipfs://Qm.../nfa007_intro.mp4",
  vaultURI: "ipfs://Qm.../nfa007_vault.json",
  vaultHash: ethers.utils.keccak256(ethers.utils.toUtf8Bytes("vault_content"))
};

// 3. Create the agent
const tx = await agentFactory.createAgent(
  "My DeFi Agent",
  "MDA",
  defiAgent.address,
  "ipfs://metadata-uri",
  extendedMetadata
);
const receipt = await tx.wait();

// 4. Get the agent address
const agentCreatedEvent = receipt.events.find(e => e.event === "AgentCreated");
const agentAddress = agentCreatedEvent.args.agent;

// 5. Fund the agent
const agent = await ethers.getContractAt("BEP007", agentAddress);
await agent.fundAgent({ value: ethers.utils.parseEther("0.1") });

// 6. Execute an action
const data = defiAgent.interface.encodeFunctionData("performSwap", [tokenA, tokenB, amount]);
await agent.executeAction(data);
```

### Working with Memory Modules

```javascript
// 1. Create module metadata
const moduleMetadata = JSON.stringify({
  context_id: "nfa007-memory-001",
  owner: ownerAddress,
  created: new Date().toISOString(),
  persona: "Strategic crypto analyst"
});

// 2. Sign the registration
const messageHash = ethers.utils.solidityKeccak256(
  ["uint256", "address", "string"],
  [tokenId, moduleAddress, moduleMetadata]
);
const signature = await wallet.signMessage(ethers.utils.arrayify(messageHash));

// 3. Register the module
await memoryRegistry.registerModule(
  tokenId,
  moduleAddress,
  moduleMetadata,
  signature
);

// 4. Check if module is approved
const isApproved = await memoryRegistry.isModuleApproved(tokenId, moduleAddress);

// 5. Get module metadata
const storedMetadata = await memoryRegistry.getModuleMetadata(tokenId, moduleAddress);
```

### Managing Vault Permissions

```javascript
// 1. Set expiry time (1 day from now)
const expiryTime = Math.floor(Date.now() / 1000) + 86400;

// 2. Sign the delegation
const messageHash = ethers.utils.solidityKeccak256(
  ["uint256", "address", "uint256"],
  [tokenId, delegateAddress, expiryTime]
);
const signature = await wallet.signMessage(ethers.utils.arrayify(messageHash));

// 3. Delegate access
await vaultManager.delegateAccess(
  tokenId,
  delegateAddress,
  expiryTime,
  signature
);

// 4. Check if address has access
const hasAccess = await vaultManager.hasVaultAccess(tokenId, delegateAddress);

// 5. Revoke access if needed
await vaultManager.revokeAccess(tokenId, delegateAddress);
```

This architecture guide provides a comprehensive overview of the BEP-007 standard and its components. For more detailed information, refer to the individual contract documentation and the BEP-007 white paper.
