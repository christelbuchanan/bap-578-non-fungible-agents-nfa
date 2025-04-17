# BEP-007: Non-Fungible Agent (NFA) Token Standard

![BEP-007 Non-Fungible Agents](https://github.com/christelbuchanan/bep007-non-fungible-agents-nfa/blob/e72d12896ae8a2afced541c962011801a144dbdf/Frame%2010.png)

## Overview

BEP-007 introduces Non-Fungible Agents (NFAs)—programmable, autonomous tokens that act as on-chain "agents" capable of executing tasks, evolving, and interacting with other contracts. Inspired by the iconic "007" designation for elite agents, this standard merges the uniqueness of NFTs with autonomous functionality, positioning BNB Chain as the home for decentralized automation.

This implementation provides a complete framework for creating, managing, and governing autonomous agent tokens on the BNB Chain.

For a comprehensive technical breakdown, read the [BEP-007 Extended White Paper: License to Automate](https://github.com/christelbuchanan/bep007-non-fungible-agents-nfa/blob/7313da87ecd24eff91850764106ad8b5a7072287/BEP-007%20_%20License%20to%20Automate.pdf).

## Key Features

- **Autonomous Behavior**: Agents execute predefined logic (e.g., trading, interacting with contracts) without manual intervention
- **Statefulness**: Each agent maintains mutable state variables stored on-chain
- **Interoperability**: Agents can interact with any smart contract on the BNB Chain, including BEP-20 and BEP-721 tokens
- **Upgradability**: Agent logic can be upgraded by their owners via proxy patterns or modular logic
- **Governance**: Protocol-level governance for parameter updates and improvements
- **Security**: Robust circuit breaker system for emergency pauses at both global and contract-specific levels
- **Extensibility**: Template system for creating specialized agent types

## Token Structure

- **Inheritance**: Extends BEP-721 (NFT standard) with additional agent-specific functions
- **Metadata**: Includes static attributes, dynamic metadata, and state variables
- **Smart Contract Design**: Implements key functions like executeAction(), setLogicAddress(), fundAgent(), and getState()

## Architecture

The BEP-007 standard consists of the following components:

### Core Contracts

- **BEP007.sol**: The main NFT contract that implements the agent token standard
- **CircuitBreaker.sol**: Emergency shutdown mechanism with global and targeted pause capabilities, controlled by governance and multi-sig for rapid response to security incidents
- **AgentFactory.sol**: Factory contract for deploying new agent tokens with customizable templates
- **BEP007Governance.sol**: Governance contract for protocol-level decisions
- **BEP007Treasury.sol**: Treasury management for fee collection and distribution

### Interfaces

- **IBEP007.sol**: Interface defining the core functionality for BEP-007 compliant tokens

### Agent Templates

- **DeFiAgent.sol**: Template for DeFi-focused agents (trading, liquidity provision)
- **GameAgent.sol**: Template for gaming-focused agents (NPCs, item management)
- **DAOAgent.sol**: Template for DAO-focused agents (voting, proposal execution)

## Use Cases

- **DeFi Agents**: Autonomous portfolio managers, liquidity providers, or arbitrage bots
- **Gaming**: NPCs that evolve, trade items, or interact with players
- **DAO Participants**: Agents voting or executing proposals based on predefined rules
- **IoT Integration**: Agents acting as digital twins for physical devices

## Getting Started

### Prerequisites

- Node.js (v14+)
- npm or yarn
- Hardhat

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bep007.git
cd bep007
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file based on `.env.example` and add your private key and BNB Chain RPC URL.

### Compilation

Compile the smart contracts:

```bash
npx hardhat compile
```

### Testing

Run the test suite:

```bash
npx hardhat test
```

### Deployment

Deploy to the BNB Chain testnet:

```bash
npx hardhat run scripts/deploy.js --network testnet
```

## Usage

### Creating an Agent

To create a new agent, you'll need to:

1. Choose or deploy an agent logic contract
2. Use the AgentFactory to create a new agent token
3. Fund the agent with BNB for gas fees

Example:

```javascript
// Deploy a logic contract (e.g., DeFiAgent)
const DeFiAgent = await ethers.getContractFactory("DeFiAgent");
const defiAgent = await DeFiAgent.deploy();
await defiAgent.deployed();

// Get the AgentFactory
const agentFactory = await ethers.getContractAt("AgentFactory", FACTORY_ADDRESS);

// Create a new agent
const tx = await agentFactory.createAgent(
  "My DeFi Agent",
  "MDA",
  defiAgent.address,
  "ipfs://metadata-uri"
);
const receipt = await tx.wait();

// Get the agent address from the event
const agentCreatedEvent = receipt.events.find(e => e.event === "AgentCreated");
const agentAddress = agentCreatedEvent.args.agent;

// Fund the agent
const agent = await ethers.getContractAt("BEP007", agentAddress);
await agent.fundAgent({ value: ethers.utils.parseEther("0.1") });
```

### Executing Agent Actions

To execute an action with your agent:

```javascript
// Encode the function call
const data = defiAgent.interface.encodeFunctionData("performSwap", [
  tokenA,
  tokenB,
  amount
]);

// Execute the action
await agent.executeAction(data);
```

### Upgrading Agent Logic

To upgrade an agent's logic:

```javascript
// Deploy new logic
const NewDeFiAgent = await ethers.getContractFactory("NewDeFiAgent");
const newDefiAgent = await NewDeFiAgent.deploy();
await newDefiAgent.deployed();

// Update the agent's logic
await agent.setLogicAddress(newDefiAgent.address);
```

### Governance

To create a governance proposal:

```javascript
// Get the governance contract
const governance = await ethers.getContractAt("BEP007Governance", GOVERNANCE_ADDRESS);

// Encode the function call for the proposal
const targetContract = TREASURY_ADDRESS;
const callData = treasuryInterface.encodeFunctionData("updateFeePercentages", [
  500, // 5% treasury fee
  300  // 3% owner fee
]);

// Create the proposal
await governance.createProposal(
  "Update fee percentages",
  callData,
  targetContract
);
```

## Security Considerations

- **Circuit Breaker**: The protocol includes a dual-layer pause mechanism:
  - Global pause for system-wide emergencies
  - Contract-specific pauses for targeted intervention
  - Controlled by both governance and emergency multi-sig for rapid response
- **Reentrancy Protection**: All fund-handling functions are protected against reentrancy attacks
- **Gas Limits**: Delegatecall operations have gas limits to prevent out-of-gas attacks
- **Access Control**: Strict access control for sensitive operations
- **Balance Management**: Agents maintain their own balance for gas fees

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgements

- OpenZeppelin for their secure contract implementations
- BNB Chain team for their support of the BEP-007 standard
