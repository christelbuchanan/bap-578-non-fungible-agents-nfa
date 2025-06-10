// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IBEP007 - Interface for Non-Fungible Agent (NFA) tokens
 * @dev This interface defines the core functionality for BEP-007 compliant tokens
 */
interface IBEP007 {
    /**
     * @dev Enum representing the current status of an agent
     */
    enum Status {
        Active,
        Paused,
        Terminated
    }

    /**
     * @dev Struct representing the state of an agent
     */
    struct State {
        uint256 balance;
        Status status;
        address owner;
        address logicAddress;
        uint256 lastActionTimestamp;
    }

    /**
     * @dev Struct representing the extended metadata of an agent
     */
    struct AgentMetadata {
        string persona; // JSON-encoded string for character traits, style, tone
        string imprint; // Short summary string for agent's role/purpose
        string voiceHash; // Reference ID to stored audio profile
        string animationURI; // URI to video or animation file
        string vaultURI; // URI to the agent's vault (extended data storage)
        bytes32 vaultHash; // Hash of the vault contents for verification
    }

    /**
     * @dev Emitted when an agent executes an action
     */
    event ActionExecuted(address indexed agent, bytes result);

    /**
     * @dev Emitted when an agent's logic is upgraded
     */
    event LogicUpgraded(address indexed agent, address oldLogic, address newLogic);

    /**
     * @dev Emitted when an agent is funded
     */
    event AgentFunded(address indexed agent, address indexed funder, uint256 amount);

    /**
     * @dev Emitted when an agent's status changes
     */
    event StatusChanged(address indexed agent, Status newStatus);

    /**
     * @dev Emitted when an agent's metadata is updated
     */
    event MetadataUpdated(uint256 indexed tokenId, string metadataURI);

    /**
     * @dev Emitted when a imprint module is registered
     */
    event ImprintModuleRegistered(uint256 indexed tokenId, address indexed moduleAddress);

    /**
     * @dev Executes an action using the agent's logic
     * @param data The encoded function call to execute
     */
    function executeAction(bytes calldata data) external;

    /**
     * @dev Updates the logic address for the agent
     * @param newLogic The address of the new logic contract
     */
    function setLogicAddress(address newLogic) external;

    /**
     * @dev Funds the agent with BNB for gas fees
     */
    function fundAgent() external payable;

    /**
     * @dev Returns the current state of the agent
     * @return The agent's state
     */
    function getState() external view returns (State memory);

    /**
     * @dev Pauses the agent
     */
    function pause() external;

    /**
     * @dev Resumes the agent
     */
    function unpause() external;

    /**
     * @dev Terminates the agent permanently
     */
    function terminate() external;

    /**
     * @dev Gets the agent's extended metadata
     * @param tokenId The ID of the agent token
     * @return The agent's extended metadata
     */
    function getAgentMetadata(uint256 tokenId) external view returns (AgentMetadata memory);

    /**
     * @dev Updates the agent's extended metadata
     * @param tokenId The ID of the agent token
     * @param metadata The new metadata
     */
    function updateAgentMetadata(uint256 tokenId, AgentMetadata memory metadata) external;
}
