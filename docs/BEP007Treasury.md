# BEP007Treasury

## Overview
The BEP007Treasury contract manages the financial aspects of the BEP-007 ecosystem, handling fee collection and distribution between the protocol treasury and agent owners. It provides a transparent and configurable fee structure for ecosystem sustainability.

## Key Features
- Fee collection and distribution mechanism
- Configurable fee percentages
- Secure fund management
- Governance-controlled withdrawals

## Contract Structure

### State Variables
- `governance`: Address of the governance contract
- `treasuryFeePercentage`: Percentage of fees kept by treasury (in basis points)
- `ownerFeePercentage`: Percentage of fees distributed to agent owners (in basis points)
- `totalBnbBalance`: Total BNB balance held by the treasury

### Events
- `FeesDistributed`: Emitted when fees are distributed
- `FeePercentagesUpdated`: Emitted when fee percentages are updated
- `FundsWithdrawn`: Emitted when funds are withdrawn from the treasury

### Functions

#### Initialization
```solidity
function initialize(
    address _governance,
    uint256 _treasuryFeePercentage,
    uint256 _ownerFeePercentage
) public initializer
```
Initializes the contract with governance address and fee percentages.

#### Fee Management
```solidity
function distributeFees(address agentOwner) external payable nonReentrant
```
Distributes incoming fees between the treasury and the agent owner.

```solidity
function updateFeePercentages(
    uint256 _treasuryFeePercentage,
    uint256 _ownerFeePercentage
) external onlyOwner
```
Updates the fee percentages for treasury and agent owners.

#### Fund Management
```solidity
function withdrawFunds(address recipient, uint256 amount) external onlyGovernance nonReentrant
```
Withdraws funds from the treasury to a specified recipient.

#### Configuration
```solidity
function setGovernance(address _governance) external onlyOwner
```
Updates the governance address.

## Security Considerations
- Reentrancy protection for all fund transfers
- Strict validation of fee percentages (must sum to ≤ 100%)
- Governance-controlled withdrawals
- Balance tracking to prevent overdrafts

## Integration Points
- Receives fees from agent operations
- Distributes portions to agent owners
- Controlled by BEP007Governance for fund management
