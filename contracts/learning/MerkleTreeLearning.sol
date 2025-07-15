// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "../interfaces/ILearningModule.sol";
import "../BEP007.sol";

/**
 * @title MerkleTreeLearning
 * @dev Implementation of Merkle tree-based learning for BEP007 agents
 */
contract MerkleTreeLearning is
    ILearningModule,
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using MerkleProofUpgradeable for bytes32[];

    // BEP007 token contract
    BEP007 public bep007Token;

    // Mapping from token ID to learning tree root
    mapping(uint256 => bytes32) private _learningRoots;

    // Mapping from token ID to learning metrics
    mapping(uint256 => LearningMetrics) private _learningMetrics;

    // Mapping from token ID to learning enabled status
    mapping(uint256 => bool) private _learningEnabled;

    // Mapping from token ID to authorized updaters
    mapping(uint256 => mapping(address => bool)) private _authorizedUpdaters;
   
    /**
     * @dev Modifier to check if the caller is authorized to update learning
     */
    modifier onlyAuthorized(uint256 tokenId) {
        address owner = bep007Token.ownerOf(tokenId);
        require(
            msg.sender == owner || _authorizedUpdaters[tokenId][msg.sender],
            "MerkleTreeLearning: not authorized"
        );
        _;
    }

    /**
     * @dev Modifier to check if learning is enabled for the agent
     */
    modifier whenLearningEnabled(uint256 tokenId) {
        require(_learningEnabled[tokenId], "MerkleTreeLearning: learning not enabled");
        _;
    }

    /**
     * @dev Initializes the contract
     * @param _bep007Token The address of the BEP007 token contract
     */
    function initialize(address payable _bep007Token) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        require(_bep007Token != address(0), "MerkleTreeLearning: token is zero address");
        bep007Token = BEP007(_bep007Token);
    }

   

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
    ) external view override returns (bool) {
        bytes32 root = _learningRoots[tokenId];
        return proof.verify(root, claim);
    }

    /**
     * @dev Gets the current learning metrics for an agent
     * @param tokenId The ID of the agent token
     * @return The learning metrics
     */
    function getLearningMetrics(
        uint256 tokenId
    ) external view override returns (LearningMetrics memory) {
        return _learningMetrics[tokenId];
    }

    /**
     * @dev Gets the current learning tree root for an agent
     * @param tokenId The ID of the agent token
     * @return The Merkle root of the learning tree
     */
    function getLearningRoot(uint256 tokenId) external view override returns (bytes32) {
        return _learningRoots[tokenId];
    }

    /**
     * @dev Checks if an agent has learning enabled
     * @param tokenId The ID of the agent token
     * @return Whether learning is enabled
     */
    function isLearningEnabled(uint256 tokenId) external view override returns (bool) {
        return _learningEnabled[tokenId];
    }

    /**
     * @dev Gets the learning module version
     * @return The version string
     */
    function getVersion() external pure override returns (string memory) {
        return "1.0.0";
    }

    /**
     * @dev Authorizes an address to update learning for an agent
     * @param tokenId The ID of the agent token
     * @param updater The address to authorize
     * @param authorized Whether to authorize or revoke
     */
    function setAuthorizedUpdater(uint256 tokenId, address updater, bool authorized) external {
        address owner = bep007Token.ownerOf(tokenId);
        require(msg.sender == owner, "MerkleTreeLearning: not token owner");

        _authorizedUpdaters[tokenId][updater] = authorized;
    }

    /**
     * @dev Checks if an address is authorized to update learning
     * @param tokenId The ID of the agent token
     * @param updater The address to check
     * @return Whether the address is authorized
     */
    function isAuthorizedUpdater(uint256 tokenId, address updater) external view returns (bool) {
        return _authorizedUpdaters[tokenId][updater];
    }

    /**
     * @dev Disables learning for an agent (emergency function)
     * @param tokenId The ID of the agent token
     */
    function disableLearning(uint256 tokenId) external {
        address owner = bep007Token.ownerOf(tokenId);
        require(msg.sender == owner, "MerkleTreeLearning: not token owner");

        _learningEnabled[tokenId] = false;
    }
}
