# AgentFactory

## Overview
The AgentFactory contract serves as a factory for deploying Non-Fungible Agent (NFA) tokens in the BEP-007 ecosystem. It creates new agent instances by cloning a reference implementation and manages template approvals for agent logic contracts.

## Key Features
- Creates new agent contracts using minimal proxy pattern
- Manages approved logic templates for agents
- Categorizes templates by type and version
- Enforces governance control over template approvals

## Contract Structure

### State Variables
- `implementation`: Address of the BEP007 implementation contract
- `governance`: Address of the governance contract
- `approvedTemplates`: Mapping of template addresses to their approval status
- `templateVersions`: Mapping of template categories to their latest version

### Events
- `AgentCreated`: Emitted when a new agent is created
- `TemplateApproved`: Emitted when a new template is approved

### Functions

#### Initialization
```solidity
function initialize(address _implementation, address _governance) public initializer
```
Initializes the contract with the implementation and governance addresses.

#### Agent Creation
```solidity
function createAgent(
    string memory name,
    string memory symbol,
    address logicAddress,
    string memory metadataURI,
    IBEP007.AgentMetadata memory extendedMetadata
) external returns (address agent)
```
Creates a new agent with extended metadata.

```solidity
function createAgent(
    string memory name,
    string memory symbol,
    address logicAddress,
    string memory metadataURI
) external returns (address agent)
```
Creates a new agent with basic metadata.

#### Template Management
```solidity
function approveTemplate(
    address template,
    string memory category,
    string memory version
) external onlyGovernance
```
Approves a new template for use in agent creation.

```solidity
function revokeTemplate(address template) external onlyGovernance
```
Revokes approval for a template.

```solidity
function getLatestTemplate(string memory category) external view returns (address)
```
Gets the latest template for a specific category.

#### Configuration
```solidity
function setImplementation(address newImplementation) external onlyGovernance
```
Updates the implementation address.

```solidity
function setGovernance(address newGovernance) external onlyGovernance
```
Updates the governance address.

## Security Considerations
- Only approved templates can be used for agent creation
- Template approval is controlled by governance
- Implementation updates are restricted to governance

## Integration Points
- Interacts with BEP007 contract for agent initialization
- Controlled by BEP007Governance for template approvals
- Used by users to create new agent instances
