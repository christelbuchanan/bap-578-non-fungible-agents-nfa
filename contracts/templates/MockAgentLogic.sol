// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockAgentLogic
 * @dev Mock contract for testing agent logic
 */
contract MockAgentLogic {
    // Event emitted when an action is executed
    event ActionExecuted(address indexed executor, bytes data);
    
    /**
     * @dev Executes a mock action
     * @param data The data to execute
     */
    function executeAction(bytes memory data) external {
        emit ActionExecuted(msg.sender, data);
    }
    
    /**
     * @dev Fallback function to handle delegatecall
     */
    fallback() external {
        emit ActionExecuted(msg.sender, msg.data);
    }
    
    /**
     * @dev Receive function to handle ETH transfers
     */
    receive() external payable {}
}
