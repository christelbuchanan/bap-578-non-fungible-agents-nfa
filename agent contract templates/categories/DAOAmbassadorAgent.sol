// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DAOAmbassadorAgent
 * @dev Template for DAO ambassador agents that speak and post for communities
 */
contract DAOAmbassadorAgent is Ownable {
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The address of the DAO contract
    address public daoContract;
    
    // The address of the DAO token
    address public daoToken;
    
    // The DAO's profile
    struct DAOProfile {
        string name;
        string mission;
        string[] values;
        string communicationStyle;
        string[] approvedTopics;
        string[] restrictedTopics;
    }
    
    // The DAO's profile
    DAOProfile public profile;
    
    // The communication history
    struct Communication {
        uint256 id;
        string communicationType; // "post", "proposal", "comment", "vote", etc.
        string platform;
        string content;
        uint256 timestamp;
        bool approved;
        address approver;
    }
    
    // The communication history
    mapping(uint256 => Communication) public communicationHistory;
    uint256 public communicationCount;
    
    // The proposal history
    struct Proposal {
        uint256 id;
        string title;
        string description;
        string[] options;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        uint256 winningOption;
    }
    
    // The proposal history
    mapping(uint256 => Proposal) public proposalHistory;
    uint256 public proposalCount;
    
    // The community engagement metrics
    struct EngagementMetrics {
        uint256 totalPosts;
        uint256 totalProposals;
        uint256 totalVotes;
        uint256 totalComments;
        uint256 activeMembers;
        uint256 lastUpdated;
    }
    
    // The community engagement metrics
    EngagementMetrics public metrics;
    
    // Event emitted when a communication is created
    event CommunicationCreated(uint256 indexed communicationId, string communicationType, string platform);
    
    // Event emitted when a communication is approved
    event CommunicationApproved(uint256 indexed communicationId, address approver);
    
    // Event emitted when a proposal is created
    event ProposalCreated(uint256 indexed proposalId, string title, uint256 startTime, uint256 endTime);
    
    // Event emitted when a proposal is executed
    event ProposalExecuted(uint256 indexed proposalId, uint256 winningOption);
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _daoContract The address of the DAO contract
     * @param _daoToken The address of the DAO token
     * @param _name The DAO's name
     * @param _mission The DAO's mission
     * @param _values The DAO's values
     * @param _communicationStyle The DAO's communication style
     * @param _approvedTopics The DAO's approved topics
     * @param _restrictedTopics The DAO's restricted topics
     */
    constructor(
        address _agentToken,
        address _daoContract,
        address _daoToken,
        string memory _name,
        string memory _mission,
        string[] memory _values,
        string memory _communicationStyle,
        string[] memory _approvedTopics,
        string[] memory _restrictedTopics
    ) {
        require(_agentToken != address(0), "DAOAmbassadorAgent: agent token is zero address");
        require(_daoContract != address(0), "DAOAmbassadorAgent: DAO contract is zero address");
        require(_daoToken != address(0), "DAOAmbassadorAgent: DAO token is zero address");
        
        agentToken = _agentToken;
        daoContract = _daoContract;
        daoToken = _daoToken;
        
        profile = DAOProfile({
            name: _name,
            mission: _mission,
            values: _values,
            communicationStyle: _communicationStyle,
            approvedTopics: _approvedTopics,
            restrictedTopics: _restrictedTopics
        });
        
        metrics = EngagementMetrics({
            totalPosts: 0,
            totalProposals: 0,
            totalVotes: 0,
            totalComments: 0,
            activeMembers: 0,
            lastUpdated: block.timestamp
        });
    }
    
    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "DAOAmbassadorAgent: caller is not agent token");
        _;
    }
    
    /**
     * @dev Modifier to check if the caller is the DAO contract
     */
    modifier onlyDAOContract() {
        require(msg.sender == daoContract, "DAOAmbassadorAgent: caller is not DAO contract");
        _;
    }
    
    /**
     * @dev Updates the DAO's profile
     * @param _name The DAO's name
     * @param _mission The DAO's mission
     * @param _values The DAO's values
     * @param _communicationStyle The DAO's communication style
     * @param _approvedTopics The DAO's approved topics
     * @param _restrictedTopics The DAO's restricted topics
     */
    function updateProfile(
        string memory _name,
        string memory _mission,
        string[] memory _values,
        string memory _communicationStyle,
        string[] memory _approvedTopics,
        string[] memory _restrictedTopics
    ) 
        external 
        onlyOwner 
    {
        profile = DAOProfile({
            name: _name,
            mission: _mission,
            values: _values,
            communicationStyle: _communicationStyle,
            approvedTopics: _approvedTopics,
            restrictedTopics: _restrictedTopics
        });
    }
    
    /**
     * @dev Creates a communication draft
     * @param _communicationType The type of communication
     * @param _platform The platform for the communication
     * @param _content The content of the communication
     * @return communicationId The ID of the new communication
     */
    function createCommunicationDraft(
        string memory _communicationType,
        string memory _platform,
        string memory _content
    ) 
        external 
        onlyAgentToken 
        returns (uint256 communicationId) 
    {
        communicationCount += 1;
        communicationId = communicationCount;
        
        communicationHistory[communicationId] = Communication({
            id: communicationId,
            communicationType: _communicationType,
            platform: _platform,
            content: _content,
            timestamp: block.timestamp,
            approved: false,
            approver: address(0)
        });
        
        emit CommunicationCreated(communicationId, _communicationType, _platform);
        
        return communicationId;
    }
    
    /**
     * @dev Approves a communication draft
     * @param _communicationId The ID of the communication
     */
    function approveCommunication(uint256 _communicationId) 
        external 
        onlyOwner 
    {
        require(_communicationId <= communicationCount && _communicationId > 0, "DAOAmbassadorAgent: communication does not exist");
        require(!communicationHistory[_communicationId].approved, "DAOAmbassadorAgent: communication already approved");
        
        communicationHistory[_communicationId].approved = true;
        communicationHistory[_communicationId].approver = msg.sender;
        
        // Update metrics
        if (keccak256(bytes(communicationHistory[_communicationId].communicationType)) == keccak256(bytes("post"))) {
            metrics.totalPosts += 1;
        } else if (keccak256(bytes(communicationHistory[_communicationId].communicationType)) == keccak256(bytes("comment"))) {
            metrics.totalComments += 1;
        }
        
        metrics.lastUpdated = block.timestamp;
        
        emit CommunicationApproved(_communicationId, msg.sender);
    }
    
    /**
     * @dev Creates a proposal
     * @param _title The title of the proposal
     * @param _description The description of the proposal
     * @param _options The options for the proposal
     * @param _startTime The start time of the proposal
     * @param _endTime The end time of the proposal
     * @return proposalId The ID of the new proposal
     */
    function createProposal(
        string memory _title,
        string memory _description,
        string[] memory _options,
        uint256 _startTime,
        uint256 _endTime
    ) 
        external 
        onlyOwner 
        returns (uint256 proposalId) 
    {
        require(_options.length > 0, "DAOAmbassadorAgent: options cannot be empty");
        require(_startTime > block.timestamp, "DAOAmbassadorAgent: start time must be in the future");
        require(_endTime > _startTime, "DAOAmbassadorAgent: end time must be after start time");
        
        proposalCount += 1;
        proposalId = proposalCount;
        
        proposalHistory[proposalId] = Proposal({
            id: proposalId,
            title: _title,
            description: _description,
            options: _options,
            startTime: _startTime,
            endTime: _endTime,
            executed: false,
            winningOption: 0
        });
        
        // Update metrics
        metrics.totalProposals += 1;
        metrics.lastUpdated = block.timestamp;
        
        emit ProposalCreated(proposalId, _title, _startTime, _endTime);
        
        return proposalId;
    }
    
    /**
     * @dev Executes a proposal
     * @param _proposalId The ID of the proposal
     * @param _winningOption The winning option of the proposal
     */
    function executeProposal(
        uint256 _proposalId,
        uint256 _winningOption
    ) 
        external 
        onlyDAOContract 
    {
        require(_proposalId <= proposalCount && _proposalId > 0, "DAOAmbassadorAgent: proposal does not exist");
        require(!proposalHistory[_proposalId].executed, "DAOAmbassadorAgent: proposal already executed");
        require(block.timestamp >= proposalHistory[_proposalId].endTime, "DAOAmbassadorAgent: proposal voting period not ended");
        require(_winningOption < proposalHistory[_proposalId].options.length, "DAOAmbassadorAgent: invalid winning option");
        
        proposalHistory[_proposalId].executed = true;
        proposalHistory[_proposalId].winningOption = _winningOption;
        
        emit ProposalExecuted(_proposalId, _winningOption);
    }
    
    /**
     * @dev Records a vote
     * @param _voter The address of the voter
     */
    function recordVote(address _voter) 
        external 
        onlyDAOContract 
    {
        require(_voter != address(0), "DAOAmbassadorAgent: voter is zero address");
        
        // Update metrics
        metrics.totalVotes += 1;
        metrics.lastUpdated = block.timestamp;
    }
    
    /**
     * @dev Updates the active members count
     * @param _activeMembers The number of active members
     */
    function updateActiveMembers(uint256 _activeMembers) 
        external 
        onlyDAOContract 
    {
        metrics.activeMembers = _activeMembers;
        metrics.lastUpdated = block.timestamp;
    }
    
    /**
     * @dev Gets the DAO's profile
     * @return The DAO's profile
     */
    function getProfile() 
        external 
        view 
        returns (DAOProfile memory) 
    {
        return profile;
    }
    
    /**
     * @dev Gets the approved communications
     * @param _count The number of communications to return
     * @return An array of approved communications
     */
    function getApprovedCommunications(uint256 _count) 
        external 
        view 
        returns (Communication[] memory) 
    {
        // Count approved communications
        uint256 approvedCount = 0;
        for (uint256 i = 1; i <= communicationCount; i++) {
            if (communicationHistory[i].approved) {
                approvedCount++;
            }
        }
        
        uint256 resultCount = _count > approvedCount ? approvedCount : _count;
        Communication[] memory approved = new Communication[](resultCount);
        
        // Fill array with approved communications
        uint256 index = 0;
        for (uint256 i = communicationCount; i > 0 && index < resultCount; i--) {
            if (communicationHistory[i].approved) {
                approved[index] = communicationHistory[i];
                index++;
            }
        }
        
        return approved;
    }
    
    /**
     * @dev Gets the pending communications
     * @return An array of pending communications
     */
    function getPendingCommunications() 
        external 
        view 
        returns (Communication[] memory) 
    {
        // Count pending communications
        uint256 pendingCount = 0;
        for (uint256 i = 1; i <= communicationCount; i++) {
            if (!communicationHistory[i].approved) {
                pendingCount++;
            }
        }
        
        Communication[] memory pending = new Communication[](pendingCount);
        
        // Fill array with pending communications
        uint256 index = 0;
        for (uint256 i = 1; i <= communicationCount; i++) {
            if (!communicationHistory[i].approved) {
                pending[index] = communicationHistory[i];
                index++;
            }
        }
        
        return pending;
    }
    
    /**
     * @dev Gets the active proposals
     * @return An array of active proposals
     */
    function getActiveProposals() 
        external 
        view 
        returns (Proposal[] memory) 
    {
        // Count active proposals
        uint256 activeCount = 0;
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (!proposalHistory[i].executed && 
                proposalHistory[i].startTime <= block.timestamp && 
                proposalHistory[i].endTime > block.timestamp) {
                activeCount++;
            }
        }
        
        Proposal[] memory active = new Proposal[](activeCount);
        
        // Fill array with active proposals
        uint256 index = 0;
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (!proposalHistory[i].executed && 
                proposalHistory[i].startTime <= block.timestamp && 
                proposalHistory[i].endTime > block.timestamp) {
                active[index] = proposalHistory[i];
                index++;
            }
        }
        
        return active;
    }
    
    /**
     * @dev Gets the engagement metrics
     * @return The engagement metrics
     */
    function getEngagementMetrics() 
        external 
        view 
        returns (EngagementMetrics memory) 
    {
        return metrics;
    }
    
    /**
     * @dev Checks if a topic is approved
     * @param _topic The topic to check
     * @return Whether the topic is approved
     */
    function isTopicApproved(string memory _topic) 
        external 
        view 
        returns (bool) 
    {
        // Check if topic is in approved topics
        for (uint256 i = 0; i < profile.approvedTopics.length; i++) {
            if (keccak256(bytes(profile.approvedTopics[i])) == keccak256(bytes(_topic))) {
                return true;
            }
        }
        
        // Check if topic is in restricted topics
        for (uint256 i = 0; i < profile.restrictedTopics.length; i++) {
            if (keccak256(bytes(profile.restrictedTopics[i])) == keccak256(bytes(_topic))) {
                return false;
            }
        }
        
        // Default to false if not explicitly approved
        return false;
    }
}
