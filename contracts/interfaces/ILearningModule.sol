// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ILearningModule - Interface for agent learning modules
 * @dev Defines the standard interface for pluggable learning systems
 */
interface ILearningModule {
    /**
     * @dev Struct representing learning metrics for an agent
     */
    struct LearningMetrics {
        uint256 totalInteractions;
        uint256 learningEvents;
        uint256 lastUpdateTimestamp;
        uint256 learningVelocity; // Rate of learning (scaled by 1e18)
        uint256 confidenceScore; // Overall confidence (scaled by 1e18)
    }

    /**
     * @dev Struct representing a learning update
     */
    struct LearningUpdate {
        bytes32 previousRoot;
        bytes32 newRoot;
        bytes32[] proof;
        bytes metadata; // Encoded learning data
    }

    /**
     * @dev Emitted when an agent's learning is updated
     */
    event LearningUpdated(
        uint256 indexed tokenId,
        bytes32 indexed previousRoot,
        bytes32 indexed newRoot,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a learning milestone is reached
     */
    event LearningMilestone(
        uint256 indexed tokenId,
        string milestone,
        uint256 value,
        uint256 timestamp
    );

    /**
     * @dev Updates the learning state for an agent
     * @param tokenId The ID of the agent token
     * @param update The learning update data
     */
    function updateLearning(
        uint256 tokenId,
        LearningUpdate calldata update
    ) external;

    /**
     * @dev Verifies a learning claim using Merkle proof
     * @param tokenId The ID of the agent token
     * @param claim The claim to verify
     * @param proof The Merkle proof
     * @return Whether the claim is valid
     */
    function verifyLearning(
        uint256 tokenId,
        bytes32 claim,
        bytes32[] calldata proof
    ) external view returns (bool);

    /**
     * @dev Gets the current learning metrics for an agent
     * @param tokenId The ID of the agent token
     * @return The learning metrics
     */
    function getLearningMetrics(uint256 tokenId) 
        external view returns (LearningMetrics memory);

    /**
     * @dev Gets the current learning tree root for an agent
     * @param tokenId The ID of the agent token
     * @return The Merkle root of the learning tree
     */
    function getLearningRoot(uint256 tokenId) 
        external view returns (bytes32);

    /**
     * @dev Checks if an agent has learning enabled
     * @param tokenId The ID of the agent token
     * @return Whether learning is enabled
     */
    function isLearningEnabled(uint256 tokenId) 
        external view returns (bool);

    /**
     * @dev Gets the learning module version
     * @return The version string
     */
    function getVersion() external pure returns (string memory);
}
