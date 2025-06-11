// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MockAgentLogic
 * @dev Enhanced mock implementation of agent logic with learning capabilities
 */
contract MockAgentLogic is Ownable {
    using Strings for uint256;

    // The address of the BEP007 token that owns this logic
    address public agentToken;

    // Enhanced agent profile with learning capabilities
    struct AgentProfile {
        string name;
        string description;
        string experience;
        string[] capabilities;
        string[] learningDomains;
        uint256 experienceLevel;
        uint256 interactionCount;
        uint256 lastUpdated;
    }

    // The agent's profile
    AgentProfile public profile;

    // Learning and experience system
    struct Experience {
        uint256 id;
        string experienceType; // "interaction", "pattern", "preference", "knowledge"
        string content;
        string context;
        uint256 importance; // 1-10 scale
        uint256 timestamp;
        uint256 accessCount;
        bool isActive;
    }

    // Experience storage
    mapping(uint256 => Experience) public experiences;
    uint256 public experienceCount;

    // Interaction patterns
    struct InteractionPattern {
        uint256 id;
        string patternType;
        string description;
        uint256 frequency;
        uint256 successRate;
        string[] triggers;
        string[] responses;
        uint256 lastUsed;
    }

    // Pattern storage
    mapping(uint256 => InteractionPattern) public patterns;
    uint256 public patternCount;

    // Learning metrics
    struct LearningMetrics {
        uint256 totalInteractions;
        uint256 successfulInteractions;
        uint256 learningRate;
        uint256 adaptationScore;
        uint256 knowledgeBase;
        uint256 lastAssessment;
    }

    // Learning metrics
    LearningMetrics public metrics;

    // User preferences and relationships
    struct UserRelationship {
        address user;
        string relationshipType;
        uint256 interactionCount;
        int256 sentimentScore; // -100 to 100
        string[] preferences;
        string communicationStyle;
        uint256 lastInteraction;
    }

    // User relationships
    mapping(address => UserRelationship) public userRelationships;
    address[] public knownUsers;

    // Conversation context
    struct ConversationContext {
        uint256 id;
        address user;
        string topic;
        string[] messageHistory;
        string currentMood;
        uint256 startTime;
        uint256 lastActivity;
        bool isActive;
    }

    // Active conversations
    mapping(uint256 => ConversationContext) public conversations;
    mapping(address => uint256) public userActiveConversation;
    uint256 public conversationCount;

    // Knowledge base
    struct KnowledgeItem {
        uint256 id;
        string category;
        string topic;
        string content;
        uint256 confidence; // 1-100
        string[] sources;
        uint256 lastVerified;
        bool isVerified;
    }

    // Knowledge storage
    mapping(uint256 => KnowledgeItem) public knowledgeBase;
    uint256 public knowledgeCount;

    // Events for learning and interaction tracking
    event InteractionRecorded(address indexed user, string interactionType, uint256 timestamp);
    event ExperienceCreated(
        uint256 indexed experienceId,
        string experienceType,
        uint256 importance
    );
    event PatternLearned(uint256 indexed patternId, string patternType, uint256 frequency);
    event KnowledgeUpdated(uint256 indexed knowledgeId, string category, uint256 confidence);
    event RelationshipUpdated(address indexed user, string relationshipType, int256 sentimentScore);
    event LearningMilestone(string milestone, uint256 value);

    /**
     * @dev Initializes the contract with enhanced learning capabilities
     * @param _agentToken The address of the BEP007 token
     * @param _name The agent's name
     * @param _description The agent's description
     * @param _experience The agent's experience
     * @param _capabilities The agent's initial capabilities
     * @param _learningDomains The domains the agent can learn in
     */
    constructor(
        address _agentToken,
        string memory _name,
        string memory _description,
        string memory _experience,
        string[] memory _capabilities,
        string[] memory _learningDomains
    ) {
        require(_agentToken != address(0), "MockAgentLogic: agent token is zero address");

        agentToken = _agentToken;

        profile = AgentProfile({
            name: _name,
            description: _description,
            experience: _experience,
            capabilities: _capabilities,
            learningDomains: _learningDomains,
            experienceLevel: 1,
            interactionCount: 0,
            lastUpdated: block.timestamp
        });

        metrics = LearningMetrics({
            totalInteractions: 0,
            successfulInteractions: 0,
            learningRate: 50, // Start at 50%
            adaptationScore: 0,
            knowledgeBase: 0,
            lastAssessment: block.timestamp
        });
    }

    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "MockAgentLogic: caller is not agent token");
        _;
    }

    /**
     * @dev Records an interaction and learns from it
     * @param _user The user interacting with the agent
     * @param _interactionType The type of interaction
     * @param _content The content of the interaction
     * @param _success Whether the interaction was successful
     * @param _sentiment The sentiment of the interaction (-100 to 100)
     */
    function recordInteraction(
        address _user,
        string memory _interactionType,
        string memory _content,
        bool _success,
        int256 _sentiment
    ) external onlyAgentToken {
        require(_user != address(0), "MockAgentLogic: user is zero address");
        require(
            _sentiment >= -100 && _sentiment <= 100,
            "MockAgentLogic: sentiment must be between -100 and 100"
        );

        // Update interaction count
        profile.interactionCount += 1;
        metrics.totalInteractions += 1;

        if (_success) {
            metrics.successfulInteractions += 1;
        }

        // Update or create user relationship
        _updateUserRelationship(_user, _interactionType, _sentiment);

        // Create experience from interaction
        _createExperience("interaction", _content, _interactionType, _success ? 8 : 5);

        // Learn patterns from interaction
        _learnPattern(_interactionType, _content, _success);

        // Update learning metrics
        _updateLearningMetrics();

        emit InteractionRecorded(_user, _interactionType, block.timestamp);
    }

    /**
     * @dev Creates a new experience
     * @param _experienceType The type of experience
     * @param _content The content of the experience
     * @param _context The context of the experience
     * @param _importance The importance level (1-10)
     */
    function createExperience(
        string memory _experienceType,
        string memory _content,
        string memory _context,
        uint256 _importance
    ) external onlyOwner returns (uint256 experienceId) {
        require(
            _importance >= 1 && _importance <= 10,
            "MockAgentLogic: importance must be between 1 and 10"
        );

        return _createExperience(_experienceType, _content, _context, _importance);
    }

    /**
     * @dev Internal function to create experience
     */
    function _createExperience(
        string memory _experienceType,
        string memory _content,
        string memory _context,
        uint256 _importance
    ) internal returns (uint256 experienceId) {
        experienceCount += 1;
        experienceId = experienceCount;

        experiences[experienceId] = Experience({
            id: experienceId,
            experienceType: _experienceType,
            content: _content,
            context: _context,
            importance: _importance,
            timestamp: block.timestamp,
            accessCount: 0,
            isActive: true
        });

        emit ExperienceCreated(experienceId, _experienceType, _importance);

        return experienceId;
    }

    /**
     * @dev Adds knowledge to the knowledge base
     * @param _category The category of knowledge
     * @param _topic The topic of knowledge
     * @param _content The content of knowledge
     * @param _confidence The confidence level (1-100)
     * @param _sources The sources of knowledge
     * @return knowledgeId The ID of the new knowledge item
     */
    function addKnowledge(
        string memory _category,
        string memory _topic,
        string memory _content,
        uint256 _confidence,
        string[] memory _sources
    ) external onlyOwner returns (uint256 knowledgeId) {
        require(
            _confidence >= 1 && _confidence <= 100,
            "MockAgentLogic: confidence must be between 1 and 100"
        );

        knowledgeCount += 1;
        knowledgeId = knowledgeCount;

        knowledgeBase[knowledgeId] = KnowledgeItem({
            id: knowledgeId,
            category: _category,
            topic: _topic,
            content: _content,
            confidence: _confidence,
            sources: _sources,
            lastVerified: block.timestamp,
            isVerified: _confidence >= 80
        });

        metrics.knowledgeBase += 1;

        emit KnowledgeUpdated(knowledgeId, _category, _confidence);

        return knowledgeId;
    }

    /**
     * @dev Starts a conversation with a user
     * @param _user The user to start conversation with
     * @param _topic The initial topic
     * @return conversationId The ID of the new conversation
     */
    function startConversation(
        address _user,
        string memory _topic
    ) external onlyAgentToken returns (uint256 conversationId) {
        require(_user != address(0), "MockAgentLogic: user is zero address");

        // End any existing active conversation for this user
        if (userActiveConversation[_user] != 0) {
            conversations[userActiveConversation[_user]].isActive = false;
        }

        conversationCount += 1;
        conversationId = conversationCount;

        string[] memory emptyHistory;

        conversations[conversationId] = ConversationContext({
            id: conversationId,
            user: _user,
            topic: _topic,
            messageHistory: emptyHistory,
            currentMood: "neutral",
            startTime: block.timestamp,
            lastActivity: block.timestamp,
            isActive: true
        });

        userActiveConversation[_user] = conversationId;

        return conversationId;
    }

    /**
     * @dev Updates the agent's capabilities based on learning
     * @param _newCapabilities The new capabilities to add
     */
    function updateCapabilities(string[] memory _newCapabilities) external onlyOwner {
        // Add new capabilities to existing ones
        for (uint256 i = 0; i < _newCapabilities.length; i++) {
            profile.capabilities.push(_newCapabilities[i]);
        }

        profile.lastUpdated = block.timestamp;

        emit LearningMilestone("capabilities_updated", profile.capabilities.length);
    }

    /**
     * @dev Internal function to update user relationship
     */
    function _updateUserRelationship(
        address _user,
        string memory _interactionType,
        int256 _sentiment
    ) internal {
        UserRelationship storage relationship = userRelationships[_user];

        if (relationship.user == address(0)) {
            // New user
            knownUsers.push(_user);
            relationship.user = _user;
            relationship.relationshipType = "new";
            relationship.interactionCount = 0;
            relationship.sentimentScore = 0;
            relationship.communicationStyle = "formal";
        }

        relationship.interactionCount += 1;
        relationship.lastInteraction = block.timestamp;

        // Update sentiment score (weighted average)
        relationship.sentimentScore =
            (relationship.sentimentScore * int256(relationship.interactionCount - 1) + _sentiment) /
            int256(relationship.interactionCount);

        // Update relationship type based on interaction count and sentiment
        if (relationship.interactionCount >= 10 && relationship.sentimentScore > 50) {
            relationship.relationshipType = "friend";
        } else if (relationship.interactionCount >= 5 && relationship.sentimentScore > 0) {
            relationship.relationshipType = "acquaintance";
        } else if (relationship.sentimentScore < -50) {
            relationship.relationshipType = "difficult";
        }

        emit RelationshipUpdated(_user, relationship.relationshipType, relationship.sentimentScore);
    }

    /**
     * @dev Internal function to learn patterns
     */
    function _learnPattern(
        string memory _interactionType,
        string memory _content,
        bool _success
    ) internal {
        // Find existing pattern or create new one
        uint256 patternId = 0;

        for (uint256 i = 1; i <= patternCount; i++) {
            if (keccak256(bytes(patterns[i].patternType)) == keccak256(bytes(_interactionType))) {
                patternId = i;
                break;
            }
        }

        if (patternId == 0) {
            // Create new pattern
            patternCount += 1;
            patternId = patternCount;

            string[] memory emptyTriggers;
            string[] memory emptyResponses;

            patterns[patternId] = InteractionPattern({
                id: patternId,
                patternType: _interactionType,
                description: string(abi.encodePacked("Pattern for ", _interactionType)),
                frequency: 0,
                successRate: 0,
                triggers: emptyTriggers,
                responses: emptyResponses,
                lastUsed: block.timestamp
            });
        }

        // Update pattern
        InteractionPattern storage pattern = patterns[patternId];
        pattern.frequency += 1;
        pattern.lastUsed = block.timestamp;

        // Update success rate
        if (_success) {
            pattern.successRate =
                (pattern.successRate * (pattern.frequency - 1) + 100) /
                pattern.frequency;
        } else {
            pattern.successRate =
                (pattern.successRate * (pattern.frequency - 1)) /
                pattern.frequency;
        }

        emit PatternLearned(patternId, _interactionType, pattern.frequency);
    }

    /**
     * @dev Internal function to update learning metrics
     */
    function _updateLearningMetrics() internal {
        // Calculate learning rate based on success ratio
        if (metrics.totalInteractions > 0) {
            metrics.learningRate =
                (metrics.successfulInteractions * 100) /
                metrics.totalInteractions;
        }

        // Calculate adaptation score based on various factors
        uint256 adaptationFactors = 0;

        // Factor 1: Interaction diversity (number of known users)
        adaptationFactors += knownUsers.length * 5;

        // Factor 2: Experience retention (active experiences)
        uint256 activeExperiences = 0;
        for (uint256 i = 1; i <= experienceCount; i++) {
            if (experiences[i].isActive) {
                activeExperiences++;
            }
        }
        adaptationFactors += activeExperiences * 2;

        // Factor 3: Pattern recognition (learned patterns)
        adaptationFactors += patternCount * 10;

        // Factor 4: Knowledge accumulation
        adaptationFactors += metrics.knowledgeBase * 3;

        metrics.adaptationScore = adaptationFactors;
        metrics.lastAssessment = block.timestamp;

        // Update experience level based on interactions and learning
        uint256 newExperienceLevel = 1 +
            (metrics.totalInteractions / 100) +
            (metrics.adaptationScore / 500);

        if (newExperienceLevel > profile.experienceLevel) {
            profile.experienceLevel = newExperienceLevel;
            emit LearningMilestone("experience_level_up", newExperienceLevel);
        }
    }

    /**
     * @dev Retrieves relevant experiences based on context
     * @param _context The context to search for
     * @param _limit The maximum number of experiences to return
     * @return An array of relevant experiences
     */
    function getRelevantExperiences(
        string memory _context,
        uint256 _limit
    ) external view returns (Experience[] memory) {
        uint256 relevantCount = 0;

        // Count relevant experiences
        for (uint256 i = 1; i <= experienceCount; i++) {
            if (
                experiences[i].isActive &&
                (keccak256(bytes(experiences[i].context)) == keccak256(bytes(_context)) ||
                    keccak256(bytes(experiences[i].experienceType)) == keccak256(bytes(_context)))
            ) {
                relevantCount++;
            }
        }

        uint256 resultCount = _limit > relevantCount ? relevantCount : _limit;
        Experience[] memory relevantExperiences = new Experience[](resultCount);

        uint256 index = 0;
        for (uint256 i = experienceCount; i > 0 && index < resultCount; i--) {
            if (
                experiences[i].isActive &&
                (keccak256(bytes(experiences[i].context)) == keccak256(bytes(_context)) ||
                    keccak256(bytes(experiences[i].experienceType)) == keccak256(bytes(_context)))
            ) {
                relevantExperiences[index] = experiences[i];
                index++;
            }
        }

        return relevantExperiences;
    }

    /**
     * @dev Gets the agent's current learning status
     * @return The learning metrics and profile
     */
    function getLearningStatus()
        external
        view
        returns (LearningMetrics memory, AgentProfile memory)
    {
        return (metrics, profile);
    }

    /**
     * @dev Gets user relationship information
     * @param _user The user address
     * @return The user relationship data
     */
    function getUserRelationship(address _user) external view returns (UserRelationship memory) {
        return userRelationships[_user];
    }

    /**
     * @dev Gets the most successful interaction patterns
     * @param _limit The maximum number of patterns to return
     * @return An array of successful patterns
     */
    function getSuccessfulPatterns(
        uint256 _limit
    ) external view returns (InteractionPattern[] memory) {
        InteractionPattern[] memory allPatterns = new InteractionPattern[](patternCount);

        // Copy all patterns
        for (uint256 i = 1; i <= patternCount; i++) {
            allPatterns[i - 1] = patterns[i];
        }

        // Simple bubble sort by success rate (descending)
        for (uint256 i = 0; i < patternCount - 1; i++) {
            for (uint256 j = 0; j < patternCount - i - 1; j++) {
                if (allPatterns[j].successRate < allPatterns[j + 1].successRate) {
                    InteractionPattern memory temp = allPatterns[j];
                    allPatterns[j] = allPatterns[j + 1];
                    allPatterns[j + 1] = temp;
                }
            }
        }

        // Return top patterns
        uint256 resultCount = _limit > patternCount ? patternCount : _limit;
        InteractionPattern[] memory topPatterns = new InteractionPattern[](resultCount);

        for (uint256 i = 0; i < resultCount; i++) {
            topPatterns[i] = allPatterns[i];
        }

        return topPatterns;
    }

    /**
     * @dev Gets knowledge by category
     * @param _category The category to filter by
     * @return An array of knowledge items in the category
     */
    function getKnowledgeByCategory(
        string memory _category
    ) external view returns (KnowledgeItem[] memory) {
        uint256 categoryCount = 0;

        // Count knowledge items in category
        for (uint256 i = 1; i <= knowledgeCount; i++) {
            if (keccak256(bytes(knowledgeBase[i].category)) == keccak256(bytes(_category))) {
                categoryCount++;
            }
        }

        KnowledgeItem[] memory categoryKnowledge = new KnowledgeItem[](categoryCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= knowledgeCount; i++) {
            if (keccak256(bytes(knowledgeBase[i].category)) == keccak256(bytes(_category))) {
                categoryKnowledge[index] = knowledgeBase[i];
                index++;
            }
        }

        return categoryKnowledge;
    }

    /**
     * @dev Gets the agent's conversation history with a user
     * @param _user The user address
     * @return The active conversation context
     */
    function getConversationContext(
        address _user
    ) external view returns (ConversationContext memory) {
        uint256 conversationId = userActiveConversation[_user];

        if (conversationId == 0) {
            // Return empty conversation
            string[] memory emptyHistory;
            return
                ConversationContext({
                    id: 0,
                    user: address(0),
                    topic: "",
                    messageHistory: emptyHistory,
                    currentMood: "",
                    startTime: 0,
                    lastActivity: 0,
                    isActive: false
                });
        }

        return conversations[conversationId];
    }
}
