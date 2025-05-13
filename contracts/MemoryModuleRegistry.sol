// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "./BEP007.sol";

/**
 * @title MemoryModuleRegistry
 * @dev Registry for agent memory modules
 * Allows agents to register approved external memory sources
 */
contract MemoryModuleRegistry is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using ECDSAUpgradeable for bytes32;

    // BEP007 token contract
    BEP007 public bep007Token;
    
    // Mapping from token ID to registered memory modules
    mapping(uint256 => address[]) private _registeredModules;
    
    // Mapping from token ID to module address to approval status
    mapping(uint256 => mapping(address => bool)) private _approvedModules;
    
    // Mapping from token ID to module address to module metadata
    mapping(uint256 => mapping(address => string)) private _moduleMetadata;

    // Events
    event ModuleRegistered(uint256 indexed tokenId, address indexed moduleAddress, string metadata);
    event ModuleApproved(uint256 indexed tokenId, address indexed moduleAddress, bool approved);
    event ModuleMetadataUpdated(uint256 indexed tokenId, address indexed moduleAddress, string metadata);
    
    /**
     * @dev Initializes the contract
     * @param _bep007Token The address of the BEP007 token contract
     */
    function initialize(address _bep007Token) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        
        require(_bep007Token != address(0), "MemoryModuleRegistry: token is zero address");
        bep007Token = BEP007(_bep007Token);
    }
    
    /**
     * @dev Registers a new memory module for an agent
     * @param tokenId The ID of the agent token
     * @param moduleAddress The address of the memory module
     * @param metadata The metadata of the memory module
     * @param signature The signature of the agent owner
     */
    function registerModule(
        uint256 tokenId,
        address moduleAddress,
        string memory metadata,
        bytes memory signature
    ) 
        external 
        nonReentrant 
    {
        require(moduleAddress != address(0), "MemoryModuleRegistry: module is zero address");
        require(!_approvedModules[tokenId][moduleAddress], "MemoryModuleRegistry: module already registered");
        
        // Verify that the token exists
        require(bep007Token.ownerOf(tokenId) != address(0), "MemoryModuleRegistry: token does not exist");
        
        // Get the owner of the token
        address owner = bep007Token.ownerOf(tokenId);
        
        // Verify the signature
        bytes32 messageHash = keccak256(abi.encodePacked(tokenId, moduleAddress, metadata));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        address signer = ethSignedMessageHash.recover(signature);
        
        require(signer == owner, "MemoryModuleRegistry: invalid signature");
        
        // Register the module
        _registeredModules[tokenId].push(moduleAddress);
        _approvedModules[tokenId][moduleAddress] = true;
        _moduleMetadata[tokenId][moduleAddress] = metadata;
        
        emit ModuleRegistered(tokenId, moduleAddress, metadata);
    }
    
    /**
     * @dev Approves or revokes a memory module
     * @param tokenId The ID of the agent token
     * @param moduleAddress The address of the memory module
     * @param approved Whether the module is approved
     */
    function setModuleApproval(
        uint256 tokenId,
        address moduleAddress,
        bool approved
    ) 
        external 
    {
        // Only the token owner can approve or revoke modules
        require(bep007Token.ownerOf(tokenId) == msg.sender, "MemoryModuleRegistry: not token owner");
        
        _approvedModules[tokenId][moduleAddress] = approved;
        
        emit ModuleApproved(tokenId, moduleAddress, approved);
    }
    
    /**
     * @dev Updates the metadata of a memory module
     * @param tokenId The ID of the agent token
     * @param moduleAddress The address of the memory module
     * @param metadata The new metadata of the memory module
     */
    function updateModuleMetadata(
        uint256 tokenId,
        address moduleAddress,
        string memory metadata
    ) 
        external 
    {
        // Only the token owner can update module metadata
        require(bep007Token.ownerOf(tokenId) == msg.sender, "MemoryModuleRegistry: not token owner");
        require(_approvedModules[tokenId][moduleAddress], "MemoryModuleRegistry: module not approved");
        
        _moduleMetadata[tokenId][moduleAddress] = metadata;
        
        emit ModuleMetadataUpdated(tokenId, moduleAddress, metadata);
    }
    
    /**
     * @dev Gets all registered modules for an agent
     * @param tokenId The ID of the agent token
     * @return An array of module addresses
     */
    function getRegisteredModules(uint256 tokenId) 
        external 
        view 
        returns (address[] memory) 
    {
        return _registeredModules[tokenId];
    }
    
    /**
     * @dev Checks if a module is approved for an agent
     * @param tokenId The ID of the agent token
     * @param moduleAddress The address of the memory module
     * @return Whether the module is approved
     */
    function isModuleApproved(uint256 tokenId, address moduleAddress) 
        external 
        view 
        returns (bool) 
    {
        return _approvedModules[tokenId][moduleAddress];
    }
    
    /**
     * @dev Gets the metadata of a memory module
     * @param tokenId The ID of the agent token
     * @param moduleAddress The address of the memory module
     * @return The metadata of the memory module
     */
    function getModuleMetadata(uint256 tokenId, address moduleAddress) 
        external 
        view 
        returns (string memory) 
    {
        return _moduleMetadata[tokenId][moduleAddress];
    }
}
