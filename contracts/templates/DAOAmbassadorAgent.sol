// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/ILearningModule.sol";

/**
 * @title DAOAmbassadorAgent
 * @dev Enhanced template for DAO ambassador agents with learning capabilities that speak and post for communities
 */
contract DAOAmbassadorAgent is Ownable, ReentrancyGuard {
    // The address of the BEP007 token that owns this logic
    address public agentToken;

    // The address of the DAO contract
    address public daoContract;

    // The address of the DAO token
    address public daoToken;

    // Learning module integration
    address public learningModule;
    bool public learningEnabled;

    // The DAO's profile
    struct DAOProfile {
        string name;
        string mission;
        string[] values;
        string communicationStyle;
        string[] approvedTopics;
        string[] restrictedTopics;
        // Learning enhancements
        uint256 communicationTone; // 0=formal, 50=balanced, 100=casual
        string[] learningObjectives;
        uint256 autonomyLevel; // 0-100 scale for decision autonomy
        uint256 communityEngagementGoal; // Target engagement rate
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
        // Learning enhancements
        uint256 engagementScore;
        uint256 sentimentScore; // 0-100 (negative to positive)
        string[] topics;
        uint256 reachEstimate;
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
        // Learning enhancements
        uint256 participationRate;
        uint256 consensusScore; // How unified the voting was
        string[] discussionTopics;
        uint256 controversyLevel; // 0-100
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
        // Learning enhancements
        uint256 averageEngagementRate;
        uint256 communityGrowthRate;
        uint256 sentimentTrend; // Overall community sentiment
        uint256 participationTrend; // Participation trend
    }

    // The community engagement metrics
    EngagementMetrics public metrics;

    // Learning-specific data structures
    struct CommunityInsights {
        string[] trendingTopics;
        uint256[] activeTimeSlots;
        string[] preferredCommunicationStyles;
        uint256 optimalProposalDuration;
        uint256 averageDecisionTime;
        uint256 lastUpdated;
    }

    CommunityInsights public communityInsights;

    // Communication effectiveness tracking
    struct CommunicationEffectiveness {
        uint256 communicationId;
        uint256 responseRate;
        uint256 positiveReactions;
        uint256 negativeReactions;
        uint256 shareCount;
        uint256 replyCount;
        uint256 effectivenessScore;
    }

    mapping(uint256 => CommunicationEffectiveness) public communicationEffectiveness;

    // Event emitted when a communication is created
    event CommunicationCreated(
        uint256 indexed communicationId,
        string communicationType,
        string platform
    );

    // Event emitted when a communication is approved
    event CommunicationApproved(uint256 indexed communicationId, address approver);

    // Event emitted when a proposal is created
    event ProposalCreated(
        uint256 indexed proposalId,
        string title,
        uint256 startTime,
        uint256 endTime
    );

    // Event emitted when a proposal is executed
    event ProposalExecuted(uint256 indexed proposalId, uint256 winningOption);

    // Learning-specific events
    event LearningInsightGenerated(string insightType, bytes data, uint256 timestamp);
    event CommunityInsightsUpdated(uint256 timestamp);
    event CommunicationEffectivenessRecorded(
        uint256 indexed communicationId,
        uint256 effectivenessScore
    );
    event AutonomousActionTaken(string actionType, bytes data, uint256 timestamp);

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
            restrictedTopics: _restrictedTopics,
            communicationTone: 50, // Default balanced tone
            learningObjectives: new string[](0),
            autonomyLevel: 25, // Default low autonomy
            communityEngagementGoal: 70 // Default 70% engagement goal
        });

        metrics = EngagementMetrics({
            totalPosts: 0,
            totalProposals: 0,
            totalVotes: 0,
            totalComments: 0,
            activeMembers: 0,
            lastUpdated: block.timestamp,
            averageEngagementRate: 0,
            communityGrowthRate: 0,
            sentimentTrend: 50, // Neutral sentiment
            participationTrend: 0
        });

        // Initialize community insights
        communityInsights = CommunityInsights({
            trendingTopics: new string[](0),
            activeTimeSlots: new uint256[](0),
            preferredCommunicationStyles: new string[](0),
            optimalProposalDuration: 7 days,
            averageDecisionTime: 3 days,
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
     * @dev Modifier to check if learning is enabled
     */
    modifier whenLearningEnabled() {
        require(
            learningEnabled && learningModule != address(0),
            "DAOAmbassadorAgent: learning not enabled"
        );
        _;
    }

    /**
     * @dev Enables learning for this agent
     * @param _learningModule The address of the learning module
     */
    function enableLearning(address _learningModule) external onlyOwner {
        require(
            _learningModule != address(0),
            "DAOAmbassadorAgent: learning module is zero address"
        );
        require(!learningEnabled, "DAOAmbassadorAgent: learning already enabled");

        learningModule = _learningModule;
        learningEnabled = true;
    }

    /**
     * @dev Records an interaction for learning purposes
     * @param interactionType The type of interaction
     * @param success Whether the interaction was successful
     * @param metadata Additional metadata about the interaction
     */
    function recordInteraction(
        string memory interactionType,
        bool success,
        bytes memory metadata
    ) external onlyAgentToken whenLearningEnabled {
        try
            ILearningModule(learningModule).recordInteraction(
                uint256(uint160(address(this))), // Use contract address as token ID
                interactionType,
                success
            )
        {
            emit LearningInsightGenerated(interactionType, metadata, block.timestamp);
        } catch {
            // Silently fail to not break agent functionality
        }
    }

    /**
     * @dev Updates the DAO's profile with learning enhancements
     * @param _name The DAO's name
     * @param _mission The DAO's mission
     * @param _values The DAO's values
     * @param _communicationStyle The DAO's communication style
     * @param _approvedTopics The DAO's approved topics
     * @param _restrictedTopics The DAO's restricted topics
     * @param _communicationTone The communication tone (0-100)
     * @param _learningObjectives The learning objectives
     * @param _autonomyLevel The autonomy level (0-100)
     * @param _communityEngagementGoal The community engagement goal
     */
    function updateProfile(
        string memory _name,
        string memory _mission,
        string[] memory _values,
        string memory _communicationStyle,
        string[] memory _approvedTopics,
        string[] memory _restrictedTopics,
        uint256 _communicationTone,
        string[] memory _learningObjectives,
        uint256 _autonomyLevel,
        uint256 _communityEngagementGoal
    ) external onlyOwner {
        require(_communicationTone <= 100, "DAOAmbassadorAgent: communication tone must be 0-100");
        require(_autonomyLevel <= 100, "DAOAmbassadorAgent: autonomy level must be 0-100");
        require(
            _communityEngagementGoal <= 100,
            "DAOAmbassadorAgent: engagement goal must be 0-100"
        );

        profile = DAOProfile({
            name: _name,
            mission: _mission,
            values: _values,
            communicationStyle: _communicationStyle,
            approvedTopics: _approvedTopics,
            restrictedTopics: _restrictedTopics,
            communicationTone: _communicationTone,
            learningObjectives: _learningObjectives,
            autonomyLevel: _autonomyLevel,
            communityEngagementGoal: _communityEngagementGoal
        });

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "profile_update",
                true,
                abi.encode(_autonomyLevel, _communityEngagementGoal)
            );
        }
    }

    /**
     * @dev Creates a communication draft with learning enhancements
     * @param _communicationType The type of communication
     * @param _platform The platform for the communication
     * @param _content The content of the communication
     * @param _topics Topics covered in the communication
     * @param _reachEstimate Estimated reach
     * @return communicationId The ID of the new communication
     */
    function createCommunicationDraft(
        string memory _communicationType,
        string memory _platform,
        string memory _content,
        string[] memory _topics,
        uint256 _reachEstimate
    ) external onlyAgentToken returns (uint256 communicationId) {
        communicationCount += 1;
        communicationId = communicationCount;

        communicationHistory[communicationId] = Communication({
            id: communicationId,
            communicationType: _communicationType,
            platform: _platform,
            content: _content,
            timestamp: block.timestamp,
            approved: false,
            approver: address(0),
            engagementScore: 0,
            sentimentScore: 50, // Default neutral sentiment
            topics: _topics,
            reachEstimate: _reachEstimate
        });

        emit CommunicationCreated(communicationId, _communicationType, _platform);

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "communication_draft",
                true,
                abi.encode(_topics, _reachEstimate)
            );
        }

        return communicationId;
    }

    /**
     * @dev Creates an autonomous communication (if autonomy level allows)
     * @param _communicationType The type of communication
     * @param _platform The platform for the communication
     * @param _content The content of the communication
     * @param _topics Topics covered in the communication
     * @return communicationId The ID of the new communication
     */
    function createAutonomousCommunication(
        string memory _communicationType,
        string memory _platform,
        string memory _content,
        string[] memory _topics
    ) external onlyAgentToken returns (uint256 communicationId) {
        require(profile.autonomyLevel >= 50, "DAOAmbassadorAgent: insufficient autonomy level");

        // Verify topics are approved
        for (uint256 i = 0; i < _topics.length; i++) {
            require(isTopicApproved(_topics[i]), "DAOAmbassadorAgent: topic not approved");
        }

        communicationCount += 1;
        communicationId = communicationCount;

        communicationHistory[communicationId] = Communication({
            id: communicationId,
            communicationType: _communicationType,
            platform: _platform,
            content: _content,
            timestamp: block.timestamp,
            approved: true, // Auto-approved for autonomous communications
            approver: address(this), // Self-approved
            engagementScore: 0,
            sentimentScore: 50,
            topics: _topics,
            reachEstimate: _estimateReach(_platform, _topics)
        });

        // Update metrics
        if (keccak256(bytes(_communicationType)) == keccak256(bytes("post"))) {
            metrics.totalPosts += 1;
        } else if (keccak256(bytes(_communicationType)) == keccak256(bytes("comment"))) {
            metrics.totalComments += 1;
        }

        metrics.lastUpdated = block.timestamp;

        emit CommunicationCreated(communicationId, _communicationType, _platform);
        emit AutonomousActionTaken(
            "autonomous_communication",
            abi.encode(communicationId),
            block.timestamp
        );

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("autonomous_communication", true, abi.encode(_topics));
        }

        return communicationId;
    }

    /**
     * @dev Records communication effectiveness
     * @param _communicationId The ID of the communication
     * @param _responseRate The response rate
     * @param _positiveReactions Number of positive reactions
     * @param _negativeReactions Number of negative reactions
     * @param _shareCount Number of shares
     * @param _replyCount Number of replies
     */
    function recordCommunicationEffectiveness(
        uint256 _communicationId,
        uint256 _responseRate,
        uint256 _positiveReactions,
        uint256 _negativeReactions,
        uint256 _shareCount,
        uint256 _replyCount
    ) external onlyOwner {
        require(
            _communicationId <= communicationCount && _communicationId > 0,
            "DAOAmbassadorAgent: communication does not exist"
        );

        uint256 totalReactions = _positiveReactions + _negativeReactions;
        uint256 sentimentScore = totalReactions > 0
            ? (_positiveReactions * 100) / totalReactions
            : 50;
        uint256 engagementScore = _responseRate + _shareCount + _replyCount;
        uint256 effectivenessScore = (sentimentScore + engagementScore) / 2;

        communicationEffectiveness[_communicationId] = CommunicationEffectiveness({
            communicationId: _communicationId,
            responseRate: _responseRate,
            positiveReactions: _positiveReactions,
            negativeReactions: _negativeReactions,
            shareCount: _shareCount,
            replyCount: _replyCount,
            effectivenessScore: effectivenessScore
        });

        // Update communication with learned metrics
        communicationHistory[_communicationId].engagementScore = engagementScore;
        communicationHistory[_communicationId].sentimentScore = sentimentScore;

        emit CommunicationEffectivenessRecorded(_communicationId, effectivenessScore);

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "effectiveness_analysis",
                true,
                abi.encode(effectivenessScore, sentimentScore)
            );
        }
    }

    /**
     * @dev Updates community insights based on learning
     * @param _trendingTopics Current trending topics
     * @param _activeTimeSlots Active time slots
     * @param _preferredCommunicationStyles Preferred communication styles
     * @param _optimalProposalDuration Optimal proposal duration
     * @param _averageDecisionTime Average decision time
     */
    function updateCommunityInsights(
        string[] memory _trendingTopics,
        uint256[] memory _activeTimeSlots,
        string[] memory _preferredCommunicationStyles,
        uint256 _optimalProposalDuration,
        uint256 _averageDecisionTime
    ) external onlyOwner {
        communityInsights = CommunityInsights({
            trendingTopics: _trendingTopics,
            activeTimeSlots: _activeTimeSlots,
            preferredCommunicationStyles: _preferredCommunicationStyles,
            optimalProposalDuration: _optimalProposalDuration,
            averageDecisionTime: _averageDecisionTime,
            lastUpdated: block.timestamp
        });

        emit CommunityInsightsUpdated(block.timestamp);

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "insights_update",
                true,
                abi.encode(_optimalProposalDuration, _averageDecisionTime)
            );
        }
    }

    /**
     * @dev Creates a proposal with learning-optimized parameters
     * @param _title The title of the proposal
     * @param _description The description of the proposal
     * @param _options The options for the proposal
     * @param _useOptimalTiming Whether to use AI-optimized timing
     * @return proposalId The ID of the new proposal
     */
    function createProposal(
        string memory _title,
        string memory _description,
        string[] memory _options,
        bool _useOptimalTiming
    ) external onlyOwner returns (uint256 proposalId) {
        require(_options.length > 0, "DAOAmbassadorAgent: options cannot be empty");

        uint256 startTime = block.timestamp;
        uint256 duration = _useOptimalTiming ? communityInsights.optimalProposalDuration : 7 days;
        uint256 endTime = startTime + duration;

        proposalCount += 1;
        proposalId = proposalCount;

        proposalHistory[proposalId] = Proposal({
            id: proposalId,
            title: _title,
            description: _description,
            options: _options,
            startTime: startTime,
            endTime: endTime,
            executed: false,
            winningOption: 0,
            participationRate: 0,
            consensusScore: 0,
            discussionTopics: new string[](0),
            controversyLevel: 0
        });

        // Update metrics
        metrics.totalProposals += 1;
        metrics.lastUpdated = block.timestamp;

        emit ProposalCreated(proposalId, _title, startTime, endTime);

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "proposal_creation",
                true,
                abi.encode(_useOptimalTiming, duration)
            );
        }

        return proposalId;
    }

    /**
     * @dev Gets learning-enhanced communication recommendations
     * @param _platform The target platform
     * @param _topic The topic to communicate about
     * @return recommendations Array of communication strategies
     */
    function getCommunicationRecommendations(
        string memory _platform,
        string memory _topic
    ) external view returns (string[] memory recommendations) {
        require(isTopicApproved(_topic), "DAOAmbassadorAgent: topic not approved");

        // Simple recommendation logic based on community insights
        string[] memory tempRecommendations = new string[](5);
        uint256 recommendationCount = 0;

        // Add timing recommendation
        if (communityInsights.activeTimeSlots.length > 0) {
            tempRecommendations[recommendationCount] = "optimal_timing";
            recommendationCount++;
        }

        // Add tone recommendation based on profile
        if (profile.communicationTone <= 30) {
            tempRecommendations[recommendationCount] = "formal_tone";
        } else if (profile.communicationTone >= 70) {
            tempRecommendations[recommendationCount] = "casual_tone";
        } else {
            tempRecommendations[recommendationCount] = "balanced_tone";
        }
        recommendationCount++;

        // Add engagement strategy
        if (metrics.averageEngagementRate < profile.communityEngagementGoal) {
            tempRecommendations[recommendationCount] = "increase_engagement";
            recommendationCount++;
        }

        // Create properly sized array
        recommendations = new string[](recommendationCount);
        for (uint256 i = 0; i < recommendationCount; i++) {
            recommendations[i] = tempRecommendations[i];
        }

        return recommendations;
    }

    /**
     * @dev Gets the DAO's learning progress
     * @return metrics The learning metrics if available
     */
    function getLearningProgress()
        external
        view
        returns (ILearningModule.LearningMetrics memory metrics)
    {
        if (learningEnabled && learningModule != address(0)) {
            try
                ILearningModule(learningModule).getLearningMetrics(uint256(uint160(address(this))))
            returns (ILearningModule.LearningMetrics memory _metrics) {
                return _metrics;
            } catch {
                // Return empty metrics if call fails
            }
        }
    }

    /**
     * @dev Internal function to estimate reach
     * @param platform The platform
     * @param topics The topics
     * @return estimated The estimated reach
     */
    function _estimateReach(
        string memory platform,
        string[] memory topics
    ) internal view returns (uint256 estimated) {
        // Simple reach estimation based on active members and topic popularity
        uint256 baseReach = metrics.activeMembers;

        // Adjust based on platform (simplified)
        if (keccak256(bytes(platform)) == keccak256(bytes("twitter"))) {
            baseReach = baseReach * 3; // Twitter has higher reach
        } else if (keccak256(bytes(platform)) == keccak256(bytes("discord"))) {
            baseReach = baseReach * 2; // Discord has medium reach
        }

        // Adjust based on topic popularity (simplified)
        for (uint256 i = 0; i < topics.length; i++) {
            for (uint256 j = 0; j < communityInsights.trendingTopics.length; j++) {
                if (
                    keccak256(bytes(topics[i])) ==
                    keccak256(bytes(communityInsights.trendingTopics[j]))
                ) {
                    baseReach = (baseReach * 120) / 100; // 20% boost for trending topics
                    break;
                }
            }
        }

        return baseReach;
    }

    // Include all original functions with learning enhancements...

    /**
     * @dev Gets the DAO's profile with learning data
     * @return The DAO's enhanced profile
     */
    function getProfile() external view returns (DAOProfile memory) {
        return profile;
    }

    /**
     * @dev Gets community insights
     * @return The current community insights
     */
    function getCommunityInsights() external view returns (CommunityInsights memory) {
        return communityInsights;
    }

    /**
     * @dev Gets communication effectiveness data
     * @param _communicationId The ID of the communication
     * @return The communication effectiveness data
     */
    function getCommunicationEffectiveness(
        uint256 _communicationId
    ) external view returns (CommunicationEffectiveness memory) {
        require(
            _communicationId <= communicationCount && _communicationId > 0,
            "DAOAmbassadorAgent: communication does not exist"
        );
        return communicationEffectiveness[_communicationId];
    }

    /**
     * @dev Gets the engagement metrics with learning enhancements
     * @return The enhanced engagement metrics
     */
    function getEngagementMetrics() external view returns (EngagementMetrics memory) {
        return metrics;
    }

    /**
     * @dev Checks if a topic is approved
     * @param _topic The topic to check
     * @return Whether the topic is approved
     */
    function isTopicApproved(string memory _topic) public view returns (bool) {
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

    // Include remaining original functions with appropriate learning enhancements...

    /**
     * @dev Approves a communication draft with effectiveness prediction
     * @param _communicationId The ID of the communication
     */
    function approveCommunication(uint256 _communicationId) external onlyOwner {
        require(
            _communicationId <= communicationCount && _communicationId > 0,
            "DAOAmbassadorAgent: communication does not exist"
        );
        require(
            !communicationHistory[_communicationId].approved,
            "DAOAmbassadorAgent: communication already approved"
        );

        communicationHistory[_communicationId].approved = true;
        communicationHistory[_communicationId].approver = msg.sender;

        // Update metrics
        if (
            keccak256(bytes(communicationHistory[_communicationId].communicationType)) ==
            keccak256(bytes("post"))
        ) {
            metrics.totalPosts += 1;
        } else if (
            keccak256(bytes(communicationHistory[_communicationId].communicationType)) ==
            keccak256(bytes("comment"))
        ) {
            metrics.totalComments += 1;
        }

        metrics.lastUpdated = block.timestamp;

        emit CommunicationApproved(_communicationId, msg.sender);

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("communication_approval", true, abi.encode(_communicationId));
        }
    }

    /**
     * @dev Executes a proposal with learning data collection
     * @param _proposalId The ID of the proposal
     * @param _winningOption The winning option of the proposal
     * @param _participationRate The participation rate
     * @param _consensusScore The consensus score
     */
    function executeProposal(
        uint256 _proposalId,
        uint256 _winningOption,
        uint256 _participationRate,
        uint256 _consensusScore
    ) external onlyDAOContract {
        require(
            _proposalId <= proposalCount && _proposalId > 0,
            "DAOAmbassadorAgent: proposal does not exist"
        );
        require(
            !proposalHistory[_proposalId].executed,
            "DAOAmbassadorAgent: proposal already executed"
        );
        require(
            block.timestamp >= proposalHistory[_proposalId].endTime,
            "DAOAmbassadorAgent: proposal voting period not ended"
        );
        require(
            _winningOption < proposalHistory[_proposalId].options.length,
            "DAOAmbassadorAgent: invalid winning option"
        );

        proposalHistory[_proposalId].executed = true;
        proposalHistory[_proposalId].winningOption = _winningOption;
        proposalHistory[_proposalId].participationRate = _participationRate;
        proposalHistory[_proposalId].consensusScore = _consensusScore;

        emit ProposalExecuted(_proposalId, _winningOption);

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "proposal_execution",
                true,
                abi.encode(_participationRate, _consensusScore)
            );
        }
    }

    /**
     * @dev Records a vote with learning data
     * @param _voter The address of the voter
     */
    function recordVote(address _voter) external onlyDAOContract {
        require(_voter != address(0), "DAOAmbassadorAgent: voter is zero address");

        // Update metrics
        metrics.totalVotes += 1;
        metrics.lastUpdated = block.timestamp;

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("vote_recorded", true, abi.encode(_voter));
        }
    }

    /**
     * @dev Updates the active members count with trend analysis
     * @param _activeMembers The number of active members
     */
    function updateActiveMembers(uint256 _activeMembers) external onlyDAOContract {
        uint256 previousMembers = metrics.activeMembers;
        metrics.activeMembers = _activeMembers;

        // Calculate growth rate
        if (previousMembers > 0) {
            if (_activeMembers > previousMembers) {
                metrics.communityGrowthRate =
                    ((_activeMembers - previousMembers) * 100) /
                    previousMembers;
            } else {
                metrics.communityGrowthRate = 0; // No negative growth tracking for simplicity
            }
        }

        metrics.lastUpdated = block.timestamp;

        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction(
                "member_update",
                true,
                abi.encode(_activeMembers, metrics.communityGrowthRate)
            );
        }
    }
}
