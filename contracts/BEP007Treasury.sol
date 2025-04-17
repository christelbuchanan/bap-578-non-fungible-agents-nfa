// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title BEP007Treasury
 * @dev Treasury contract for the BEP-007 ecosystem
 * Handles fee collection and distribution
 */
contract BEP007Treasury is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    // Governance contract address
    address public governance;
    
    // Fee percentages (in basis points, 1% = 100)
    uint256 public treasuryFeePercentage; // Fee kept by treasury
    uint256 public ownerFeePercentage;    // Fee distributed to agent owner
    
    // Total BNB balance held by treasury
    uint256 public totalBnbBalance;
    
    // Events
    event FeesDistributed(address indexed recipient, uint256 treasuryAmount, uint256 ownerAmount);
    event FeePercentagesUpdated(uint256 treasuryFeePercentage, uint256 ownerFeePercentage);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    
    /**
     * @dev Initializes the contract
     * @param _governance The address of the governance contract
     * @param _treasuryFeePercentage The percentage of fees kept by treasury (in basis points)
     * @param _ownerFeePercentage The percentage of fees distributed to agent owner (in basis points)
     */
    function initialize(
        address _governance,
        uint256 _treasuryFeePercentage,
        uint256 _ownerFeePercentage
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        
        require(_governance != address(0), "BEP007Treasury: governance is zero address");
        require(
            _treasuryFeePercentage + _ownerFeePercentage <= 10000,
            "BEP007Treasury: fee percentages exceed 100%"
        );
        
        governance = _governance;
        treasuryFeePercentage = _treasuryFeePercentage;
        ownerFeePercentage = _ownerFeePercentage;
        totalBnbBalance = 0;
    }
    
    /**
     * @dev Modifier to check if the caller is the governance contract
     */
    modifier onlyGovernance() {
        require(msg.sender == governance, "BEP007Treasury: caller is not governance");
        _;
    }
    
    /**
     * @dev Distributes fees between treasury and agent owner
     * @param agentOwner The address of the agent owner
     */
    function distributeFees(address agentOwner) external payable nonReentrant {
        require(agentOwner != address(0), "BEP007Treasury: owner is zero address");
        require(msg.value > 0, "BEP007Treasury: no value sent");
        
        uint256 totalAmount = msg.value;
        
        // Calculate fee amounts
        uint256 treasuryAmount = (totalAmount * treasuryFeePercentage) / 10000;
        uint256 ownerAmount = (totalAmount * ownerFeePercentage) / 10000;
        
        // Update treasury balance
        totalBnbBalance += treasuryAmount;
        
        // Transfer owner fee
        if (ownerAmount > 0) {
            (bool success, ) = agentOwner.call{value: ownerAmount}("");
            require(success, "BEP007Treasury: owner fee transfer failed");
        }
        
        // Keep remaining amount in contract
        uint256 remainingAmount = totalAmount - treasuryAmount - ownerAmount;
        if (remainingAmount > 0) {
            totalBnbBalance += remainingAmount;
        }
        
        emit FeesDistributed(agentOwner, treasuryAmount, ownerAmount);
    }
    
    /**
     * @dev Updates fee percentages
     * @param _treasuryFeePercentage The new treasury fee percentage (in basis points)
     * @param _ownerFeePercentage The new owner fee percentage (in basis points)
     */
    function updateFeePercentages(
        uint256 _treasuryFeePercentage,
        uint256 _ownerFeePercentage
    ) external onlyOwner {
        require(
            _treasuryFeePercentage + _ownerFeePercentage <= 10000,
            "BEP007Treasury: fee percentages exceed 100%"
        );
        
        treasuryFeePercentage = _treasuryFeePercentage;
        ownerFeePercentage = _ownerFeePercentage;
        
        emit FeePercentagesUpdated(_treasuryFeePercentage, _ownerFeePercentage);
    }
    
    /**
     * @dev Withdraws funds from treasury (only governance)
     * @param recipient The address to receive the funds
     * @param amount The amount to withdraw
     */
    function withdrawFunds(address recipient, uint256 amount) external onlyGovernance nonReentrant {
        require(recipient != address(0), "BEP007Treasury: recipient is zero address");
        require(amount > 0, "BEP007Treasury: amount is zero");
        require(amount <= totalBnbBalance, "BEP007Treasury: insufficient balance");
        
        totalBnbBalance -= amount;
        
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "BEP007Treasury: transfer failed");
        
        emit FundsWithdrawn(recipient, amount);
    }
    
    /**
     * @dev Sets the governance address
     * @param _governance The new governance address
     */
    function setGovernance(address _governance) external onlyOwner {
        require(_governance != address(0), "BEP007Treasury: governance is zero address");
        governance = _governance;
    }
    
    /**
     * @dev Fallback function to receive BNB
     */
    receive() external payable {
        totalBnbBalance += msg.value;
    }
}
