# MockAgentLogic

## Overview
The MockAgentLogic contract serves as a test template for the BEP-007 ecosystem, providing a simplified implementation of agent logic for testing and demonstration purposes. It implements basic functionality to validate the agent interaction model without complex business logic, with optional learning capabilities for testing advanced features.

## Architecture Paths

### 🚀 **Path 1: Basic Mock Agent (Default)**
- **Perfect for**: Unit testing and basic integration testing
- **Benefits**: Simple, predictable behavior for test validation
- **Learning**: Static test data and fixed responses
- **Gas Cost**: Minimal (standard ERC721 operations)

### 🧠 **Path 2: Learning Mock Agent (Advanced)**
- **Perfect for**: Testing learning capabilities and advanced features
- **Benefits**: Validates learning mechanisms and data integrity
- **Learning**: Simulated learning patterns for comprehensive testing
- **Gas Cost**: Optimized (only learning roots stored on-chain)

## Key Features

### Core Testing Capabilities (Both Paths)
- Basic agent operations for testing
- Simplified state management
- Event logging for verification
- Test-friendly interfaces

### Learning Testing Features (Path 2 Only)
- Learning mechanism validation
- Merkle tree proof testing
- Data integrity verification
- Learning progression simulation

## Contract Structure

### State Variables
```solidity
// Basic test state
mapping(string => string) public testData;
uint256 public operationCounter;
bool public testFlag;

// Learning test state (Path 2 only)
mapping(uint256 => bytes32) public learningRoots;
mapping(uint256 => uint256) public learningVersions;
mapping(address => bool) public authorizedLearners;
```

### Functions

#### Basic Operations (Both Paths)
```solidity
function performAction(string calldata actionName) external
```
Performs a named action and emits an event for test verification.

```solidity
function storeData(string calldata key, string calldata value) external
```
Stores key-value data in the agent's test state.

```solidity
function retrieveData(string calldata key) external view returns (string memory)
```
Retrieves stored test data by key.

```solidity
function incrementCounter() external returns (uint256)
```
Increments and returns an internal counter for sequence testing.

```solidity
function emitTestEvent(string calldata message) external
```
Emits a test event with a custom message for event testing.

```solidity
function simulateFailure() external
```
Deliberately fails to test error handling mechanisms.

#### Mock Interactions (Both Paths)
```solidity
function mockExternalCall(address target, bytes calldata data) external returns (bool, bytes memory)
```
Simulates calling an external contract for integration testing.

```solidity
function mockTokenTransfer(address token, address recipient, uint256 amount) external returns (bool)
```
Simulates a token transfer operation for economic testing.

#### Learning Test Functions (Path 2 Only)
```solidity
function initializeLearning(uint256 tokenId, bytes32 initialRoot) external
```
Initializes learning capabilities for a test agent.

```solidity
function updateLearning(uint256 tokenId, bytes32 newRoot, bytes32[] calldata proof) external
```
Updates learning state with Merkle proof validation.

```solidity
function simulateLearningProgress(uint256 tokenId, uint256 steps) external
```
Simulates learning progression for testing learning algorithms.

```solidity
function verifyLearningClaim(uint256 tokenId, bytes32 claim, bytes32[] calldata proof) external view returns (bool)
```
Verifies learning claims against stored Merkle roots.

```solidity
function getLearningMetrics(uint256 tokenId) external view returns (uint256 version, bytes32 root, uint256 timestamp)
```
Retrieves learning metrics for test validation.

## Implementation Examples

### Basic Mock Agent (Path 1)

```javascript
// Deploy basic mock agent for testing
const mockMetadata = {
  persona: "Test agent for validation and debugging",
  experience: "Stores test data and performs basic operations",
  voiceHash: "",
  animationURI: "",
  vaultURI: "ipfs://Qm.../test-vault.json",
  vaultHash: ethers.utils.keccak256("test_vault_content"),
  // Learning disabled for basic testing
  learningEnabled: false,
  learningModule: ethers.constants.AddressZero,
  learningTreeRoot: ethers.constants.HashZero,
  learningVersion: 0
};

const tx = await bep007Enhanced.createAgent(
  testAddress,
  mockAgentLogicAddress,
  "ipfs://mock-metadata.json",
  mockMetadata
);

// Test basic operations
await mockAgent.performAction("test_action");
await mockAgent.storeData("test_key", "test_value");
const result = await mockAgent.retrieveData("test_key");
```

### Learning Mock Agent (Path 2)

```javascript
// Deploy learning mock agent for advanced testing
const learningMockMetadata = {
  persona: "Advanced test agent with learning capabilities",
  experience: "Tests learning mechanisms and data integrity validation",
  voiceHash: "bafkreimock2akiscaild...",
  animationURI: "ipfs://Qm.../test-avatar.mp4",
  vaultURI: "ipfs://Qm.../learning-test-vault.json",
  vaultHash: ethers.utils.keccak256("learning_test_vault_content"),
  // Learning enabled for advanced testing
  learningEnabled: true,
  learningModule: merkleTreeLearning.address,
  learningTreeRoot: initialTestLearningRoot,
  learningVersion: 1
};

const tx = await bep007Enhanced.createAgent(
  testAddress,
  mockAgentLogicAddress,
  "ipfs://learning-mock-metadata.json",
  learningMockMetadata
);

// Test learning operations
await mockAgent.initializeLearning(tokenId, testRoot);
await mockAgent.updateLearning(tokenId, newRoot, merkleProof);
const isValid = await mockAgent.verifyLearningClaim(tokenId, testClaim, proof);
```

## Test Learning Tree Structure (Path 2)

```json
{
  "root": "0x...",
  "branches": {
    "testOperations": {
      "basicOperations": {
        "performAction": { count: 25, successRate: 1.0, avgGasUsed: 45000 },
        "storeData": { count: 18, successRate: 1.0, avgGasUsed: 52000 },
        "retrieveData": { count: 32, successRate: 1.0, avgGasUsed: 23000 }
      },
      "mockInteractions": {
        "externalCalls": { count: 12, successRate: 0.92, avgGasUsed: 78000 },
        "tokenTransfers": { count: 8, successRate: 1.0, avgGasUsed: 65000 }
      }
    },
    "learningValidation": {
      "merkleProofs": {
        "validProofs": 45,
        "invalidProofs": 3,
        "verificationSuccessRate": 0.94,
        "avgVerificationGas": 35000
      },
      "stateUpdates": {
        "successfulUpdates": 23,
        "failedUpdates": 2,
        "updateSuccessRate": 0.92,
        "avgUpdateGas": 68000
      }
    },
    "performanceMetrics": {
      "gasOptimization": {
        "baselineGas": 50000,
        "optimizedGas": 42000,
        "improvement": 0.16
      },
      "executionTime": {
        "avgExecutionTime": "125ms",
        "maxExecutionTime": "340ms",
        "timeoutRate": 0.0
      }
    }
  },
  "metrics": {
    "totalTestOperations": 156,
    "learningUpdates": 25,
    "lastUpdated": "2025-01-20T10:00:00Z",
    "testCoverage": 0.95,
    "overallSuccessRate": 0.96
  }
}
```

## Test Scenarios

### Basic Testing (Path 1)
1. **Function Execution**: Verify all basic functions execute correctly
2. **State Management**: Test data storage and retrieval
3. **Event Emission**: Validate event logging and parameters
4. **Error Handling**: Test failure scenarios and error messages

### Learning Testing (Path 2)
1. **Learning Initialization**: Test learning capability setup
2. **Merkle Proof Validation**: Verify proof generation and verification
3. **State Progression**: Test learning state updates and versioning
4. **Data Integrity**: Validate learning data consistency
5. **Performance Testing**: Measure gas costs and execution times

## Security Testing

### Standard Security Tests (Both Paths)
- **Access Control**: Verify only authorized addresses can perform operations
- **Input Validation**: Test with invalid inputs and edge cases
- **State Consistency**: Ensure state remains consistent across operations
- **Reentrancy Protection**: Test against reentrancy attacks

### Learning Security Tests (Path 2 Only)
- **Proof Validation**: Test with invalid Merkle proofs
- **Learning Rate Limits**: Verify learning update frequency limits
- **Data Tampering**: Test resistance to learning data manipulation
- **Authorization Checks**: Verify learning update authorization

## Integration Testing

### BEP007 Integration
```javascript
// Test agent creation and basic operations
describe("MockAgent BEP007 Integration", () => {
  it("should create agent with mock logic", async () => {
    const tx = await bep007Enhanced.createAgent(
      owner.address,
      mockLogic.address,
      "ipfs://test-metadata.json",
      mockMetadata
    );
    expect(tx).to.emit(bep007Enhanced, "AgentCreated");
  });

  it("should execute mock operations", async () => {
    await mockAgent.performAction("integration_test");
    const counter = await mockAgent.incrementCounter();
    expect(counter).to.equal(1);
  });
});
```

### Learning Integration
```javascript
// Test learning capabilities
describe("MockAgent Learning Integration", () => {
  it("should initialize learning", async () => {
    await mockAgent.initializeLearning(tokenId, testRoot);
    const metrics = await mockAgent.getLearningMetrics(tokenId);
    expect(metrics.root).to.equal(testRoot);
  });

  it("should update learning with valid proof", async () => {
    const tx = await mockAgent.updateLearning(tokenId, newRoot, proof);
    expect(tx).to.emit(mockAgent, "LearningUpdated");
  });
});
```

## Usage Scenarios

### Development Testing
1. **Unit Testing**: Test individual agent functions and behaviors
2. **Integration Testing**: Validate agent interaction with BEP007 contract
3. **Performance Testing**: Measure gas costs and execution efficiency
4. **Regression Testing**: Ensure new features don't break existing functionality

### Learning System Testing
1. **Algorithm Validation**: Test learning algorithms and data structures
2. **Proof System Testing**: Validate Merkle tree proof generation and verification
3. **State Management**: Test learning state transitions and versioning
4. **Security Testing**: Verify learning system security and integrity

### Demonstration and Onboarding
1. **Developer Onboarding**: Provide simple examples for new developers
2. **Feature Demonstration**: Showcase agent capabilities and learning features
3. **Documentation Examples**: Provide working examples for documentation
4. **Workshop Materials**: Use in educational workshops and tutorials

## Getting Started

### For Basic Mock Testing
1. Deploy MockAgentLogic contract
2. Create mock agent using BEP007Enhanced
3. Execute test operations and verify results
4. Use for unit and integration testing

### For Learning Mock Testing
1. Deploy MerkleTreeLearning contract
2. Create learning mock agent with learning enabled
3. Test learning operations and proof validation
4. Use for advanced feature testing and validation

The MockAgentLogic template provides comprehensive testing capabilities for both basic and advanced BEP007 features, ensuring robust validation of the agent ecosystem.
