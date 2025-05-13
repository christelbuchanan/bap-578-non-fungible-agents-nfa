// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "./BEP007.sol";
import "./interfaces/IBEP007.sol";

/**
 * @title AgentFactory
 * @dev Factory contract for deploying Non-Fungible Agent (NFA) tokens
 */
contract AgentFactory is Initializable, OwnableUpgradeable {
    // The address of the BEP007 implementation contract
    address public implementation;
    
    // The address of the governance contract
    address public governance;
    
    // Mapping of template addresses to their approval status
    mapping(address => bool) public approvedTemplates;
    
    // Mapping of template categories to their latest version
    mapping(string => address) public templateVersions;
    
    // Event emitted when a new agent is created
    event AgentCreated(address indexed agent, address indexed owner, address logic);
    
    // Event emitted when a new template is approved
    event TemplateApproved(address indexed template, string category, string version);
    
    /**
     * @dev Initializes the contract
     * @param _implementation The address of the BEP007 implementation contract
     * @param _governance The address of the governance contract
     */
    function initialize(address _implementation, address _governance) public initializer {
        __Ownable_init();
        
        require(_implementation != address(0), "AgentFactory: implementation is zero address");
        require(_governance != address(0), "AgentFactory: governance is zero address");
        
        implementation = _implementation;
        governance = _governance;
    }
    
    /**
     * @dev Modifier to check if the caller is the governance contract
     */
    modifier onlyGovernance() {
        require(msg.sender == governance, "AgentFactory: caller is not governance");
        _;
    }
    
    /**
     * @dev Creates a new agent with extended metadata
     * @param name The name of the agent token collection
     * @param symbol The symbol of the agent token collection
     * @param logicAddress The address of the logic contract
     * @param metadataURI The URI for the agent's metadata
     * @param extendedMetadata The extended metadata for the agent
     * @return agent The address of the new agent contract
     */
    function createAgent(
        string memory name,
        string memory symbol,
        address logicAddress,
        string memory metadataURI,
        IBEP007.AgentMetadata memory extendedMetadata
    ) 
        external 
        returns (address agent) 
    {
        require(approvedTemplates[logicAddress], "AgentFactory: logic template not approved");
        
        // Create a new clone of the implementation
        agent = ClonesUpgradeable.clone(implementation);
        
        // Initialize the new agent
        BEP007(agent).initialize(name, symbol, governance);
        
        // Create the agent token with extended metadata
        BEP007(agent).createAgent(msg.sender, logicAddress, metadataURI, extendedMetadata);
        
        emit AgentCreated(agent, msg.sender, logicAddress);
        
        return agent;
    }
    
    /**
     * @dev Creates a new agent with basic metadata
     * @param name The name of the agent token collection
     * @param symbol The symbol of the agent token collection
     * @param logicAddress The address of the logic contract
     * @param metadataURI The URI for the agent's metadata
     * @return agent The address of the new agent contract
     */
    function createAgent(
        string memory name,
        string memory symbol,
        address logicAddress,
        string memory metadataURI
    ) 
        external 
        returns (address agent) 
    {
        // Create empty extended metadata
        IBEP007.AgentMetadata memory emptyMetadata = IBEP007.AgentMetadata({
            persona: "",
            memory: "",
            voiceHash: "",
            animationURI: "",
            vaultURI: "",
            vaultHash: bytes32(0)
        });
        
        return this.createAgent(name, symbol, logicAddress, metadataURI, emptyMetadata);
    }
    
    /**
     * @dev Approves a new template
     * @param template The address of the template contract
     * @param category The category of the template
     * @param version The version of the template
     */
    function approveTemplate(
        address template,
        string memory category,
        string memory version
    ) 
        external 
        onlyGovernance 
    {
        require(template != address(0), "AgentFactory: template is zero address");
        
        approvedTemplates[template] = true;
        templateVersions[category] = template;
        
        emit TemplateApproved(template, category, version);
    }
    
    /**
     * @dev Revokes approval for a template
     * @param template The address of the template contract
     */
    function revokeTemplate(address template) 
        external 
        onlyGovernance 
    {
        require(approvedTemplates[template], "AgentFactory: template not approved");
        
        approvedTemplates[template] = false;
    }
    
    /**
     * @dev Updates the implementation address
     * @param newImplementation The address of the new implementation contract
     */
    function setImplementation(address newImplementation) 
        external 
        onlyGovernance 
    {
        require(newImplementation != address(0), "AgentFactory: implementation is zero address");
        
        implementation = newImplementation;
    }
    
    /**
     * @dev Updates the governance address
     * @param newGovernance The address of the new governance contract
     */
    function setGovernance(address newGovernance) 
        external 
        onlyGovernance 
    {
        require(newGovernance != address(0), "AgentFactory: governance is zero address");
        
        governance = newGovernance;
    }
    
    /**
     * @dev Gets the latest template for a category
     * @param category The category of the template
     * @return The address of the latest template
     */
    function getLatestTemplate(string memory category) 
        external 
        view 
        returns (address) 
    {
        address template = templateVersions[category];
        require(template != address(0), "AgentFactory: no template for category");
        
        return template;
    }
}
