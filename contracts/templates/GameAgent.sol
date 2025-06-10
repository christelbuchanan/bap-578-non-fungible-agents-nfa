// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/ILearningModule.sol";

/**
 * @title GameAgent
 * @dev Enhanced template for game agents that can interact with players and evolve over time with learning capabilities
 */
contract GameAgent is Ownable {
    using Strings for uint256;

    // The address of the BEP007 token that owns this logic
    address public agentToken;

    // The address of the game contract
    address public gameContract;

    // Learning module integration
    address public learningModule;
    bool public learningEnabled;
    uint256 public learningVersion;

    // Enhanced agent attributes with learning capabilities
    struct Attributes {
        uint256 strength;
        uint256 intelligence;
        uint256 agility;
        uint256 charisma;
        uint256 luck;
        uint256 experience;
        uint256 level;
        // Learning enhancements
        uint256 adaptability; // How quickly the agent learns (0-100)
        uint256 imprintCapacity; // How much the agent can remember (0-100)
        uint256 strategicThinking; // Strategic planning ability (0-100)
        uint256 socialIntelligence; // Understanding of player behavior (0-100)
    }

    // Player behavior analysis for learning
    struct PlayerBehavior {
        address player;
        uint256 aggressionLevel; // Player's aggression (0-100)
        uint256 riskTolerance; // Risk tolerance (0-100)
        uint256 skillLevel; // Estimated skill level (0-100)
        uint256 predictability; // How predictable the player is (0-100)
        uint256 cooperationLevel; // Tendency to cooperate (0-100)
        uint256 lastInteraction; // Timestamp of last interaction
        uint256 totalInteractions; // Total number of interactions
        uint256 winRate; // Win rate against this player (0-100)
    }

    // Game strategy with learning adaptations
    struct GameStrategy {
        uint256 aggressionLevel; // How aggressive to be (0-100)
        uint256 riskTaking; // Risk taking propensity (0-100)
        uint256 cooperationTendency; // Tendency to cooperate (0-100)
        uint256 adaptationRate; // How quickly to adapt strategy (0-100)
        uint256 confidenceThreshold; // Minimum confidence to act (scaled by 1e18)
        uint256 learningWeight; // Weight given to learning insights (0-100)
        bool adaptiveStrategy; // Whether to adapt based on learning
        bool playerSpecificStrategy; // Whether to use player-specific strategies
    }

    // Enhanced interaction record with learning data
    struct InteractionRecord {
        uint256 timestamp;
        address player;
        string interactionType; // Type of interaction (combat, trade, dialogue, etc.)
        uint256 agentAction; // What action the agent took
        uint256 playerAction; // What action the player took
        bool wasSuccessful; // Whether the interaction was successful for the agent
        uint256 confidenceLevel; // Agent's confidence when taking action
        bool wasLearningBased; // Whether learning influenced the decision
        uint256 outcomeScore; // Score representing the outcome (0-100)
        bytes32 contextHash; // Hash of the game context
    }

    // Learning metrics for game interactions
    struct GameLearningMetrics {
        uint256 totalInteractions;
        uint256 successfulInteractions;
        uint256 totalPlayers;
        uint256 averageConfidence;
        uint256 adaptationCount;
        uint256 strategyEffectiveness; // Overall strategy effectiveness (0-100)
        uint256 playerPredictionAccuracy; // Accuracy of player behavior predictions (0-100)
        uint256 lastLearningUpdate;
        uint256 experienceGainRate; // Rate of experience gain
    }

    // The agent's enhanced attributes
    Attributes public attributes;

    // The agent's game strategy
    GameStrategy public strategy;

    // The agent's inventory
    struct InventoryItem {
        uint256 itemId;
        uint256 quantity;
        bool equipped;
        uint256 effectiveness; // Learned effectiveness of this item (0-100)
        uint256 usageCount; // How many times this item has been used
    }

    // The agent's inventory
    mapping(uint256 => InventoryItem) public inventory;
    uint256 public inventoryCount;

    // Enhanced quest system with learning
    struct Quest {
        uint256 questId;
        bool completed;
        uint256 progress;
        uint256 difficulty; // Learned difficulty (0-100)
        uint256 successProbability; // Predicted success probability (0-100)
        uint256 attempts; // Number of attempts
        string questType; // Type of quest for learning categorization
    }

    // The agent's quest log
    mapping(uint256 => Quest) public quests;
    uint256 public questCount;

    // Enhanced dialogue system with learning
    struct DialogueOption {
        string text;
        uint256 effectiveness; // Learned effectiveness (0-100)
        uint256 usageCount; // How many times used
        string context; // Context where this dialogue works best
        uint256 playerTypeAffinity; // Which player types respond well (bitmask)
    }

    // The agent's dialogue options
    mapping(uint256 => DialogueOption) public dialogueOptions;
    uint256 public dialogueCount;

    // Player behavior tracking
    mapping(address => PlayerBehavior) public playerBehaviors;
    address[] public trackedPlayers;
    uint256 public trackedPlayerCount;

    // Interaction history with learning data
    mapping(uint256 => InteractionRecord) public interactionHistory;
    uint256 public interactionCount;

    // Learning metrics
    GameLearningMetrics public learningMetrics;

    // Combat effectiveness tracking
    mapping(string => uint256) public combatEffectiveness; // combat type => effectiveness score

    // Event emitted when the agent levels up
    event LevelUp(uint256 newLevel, uint256 attributeGains);

    // Event emitted when the agent completes a quest
    event QuestCompleted(uint256 questId, uint256 experienceGained, bool wasLearningBased);

    // Event emitted when the agent acquires an item
    event ItemAcquired(uint256 itemId, uint256 quantity, uint256 predictedEffectiveness);

    // Event emitted when learning is enabled/disabled
    event LearningToggled(bool enabled, address learningModule);

    // Event emitted when player behavior is analyzed
    event PlayerBehaviorAnalyzed(
        address indexed player,
        uint256 aggressionLevel,
        uint256 skillLevel,
        uint256 predictability
    );

    // Event emitted when strategy is adapted
    event StrategyAdapted(
        uint256 oldAggression,
        uint256 newAggression,
        uint256 oldRiskTaking,
        uint256 newRiskTaking,
        string reason
    );

    // Event emitted when learning metrics are updated
    event LearningMetricsUpdated(
        uint256 totalInteractions,
        uint256 successfulInteractions,
        uint256 strategyEffectiveness
    );

    // Event emitted when an interaction occurs
    event InteractionRecorded(
        address indexed player,
        string interactionType,
        bool wasSuccessful,
        uint256 confidence,
        bool learningBased
    );

    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _gameContract The address of the game contract
     */
    constructor(address _agentToken, address _gameContract) {
        require(_agentToken != address(0), "GameAgent: agent token is zero address");
        require(_gameContract != address(0), "GameAgent: game contract is zero address");

        agentToken = _agentToken;
        gameContract = _gameContract;

        // Initialize enhanced attributes with learning capabilities
        attributes = Attributes({
            strength: 10,
            intelligence: 10,
            agility: 10,
            charisma: 10,
            luck: 10,
            experience: 0,
            level: 1,
            adaptability: 50,
            imprintCapacity: 50,
            strategicThinking: 50,
            socialIntelligence: 50
        });

        // Initialize enhanced game strategy
        strategy = GameStrategy({
            aggressionLevel: 50,
            riskTaking: 50,
            cooperationTendency: 50,
            adaptationRate: 30,
            confidenceThreshold: 70e16, // 70% confidence minimum
            learningWeight: 50, // 50% weight to learning
            adaptiveStrategy: false, // Disabled by default
            playerSpecificStrategy: false // Disabled by default
        });

        // Initialize enhanced dialogue options
        dialogueCount = 3;
        dialogueOptions[1] = DialogueOption({
            text: "Greetings, adventurer!",
            effectiveness: 50,
            usageCount: 0,
            context: "greeting",
            playerTypeAffinity: 0xFFFFFFFF // Works with all player types initially
        });
        dialogueOptions[2] = DialogueOption({
            text: "I have a quest for you.",
            effectiveness: 50,
            usageCount: 0,
            context: "quest_offering",
            playerTypeAffinity: 0xFFFFFFFF
        });
        dialogueOptions[3] = DialogueOption({
            text: "Would you like to trade?",
            effectiveness: 50,
            usageCount: 0,
            context: "trading",
            playerTypeAffinity: 0xFFFFFFFF
        });

        // Initialize learning metrics
        learningMetrics = GameLearningMetrics({
            totalInteractions: 0,
            successfulInteractions: 0,
            totalPlayers: 0,
            averageConfidence: 0,
            adaptationCount: 0,
            strategyEffectiveness: 50, // Start neutral
            playerPredictionAccuracy: 50,
            lastLearningUpdate: block.timestamp,
            experienceGainRate: 100 // Base rate
        });
    }

    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "GameAgent: caller is not agent token");
        _;
    }

    /**
     * @dev Modifier to check if the caller is the game contract
     */
    modifier onlyGameContract() {
        require(msg.sender == gameContract, "GameAgent: caller is not game contract");
        _;
    }

    /**
     * @dev Enables learning for the game agent
     * @param _learningModule The address of the learning module
     * @param _confidenceThreshold The minimum confidence threshold for actions
     * @param _learningWeight The weight given to learning recommendations (0-100)
     * @param _adaptiveStrategy Whether to enable adaptive strategy
     * @param _playerSpecificStrategy Whether to enable player-specific strategies
     */
    function enableLearning(
        address _learningModule,
        uint256 _confidenceThreshold,
        uint256 _learningWeight,
        bool _adaptiveStrategy,
        bool _playerSpecificStrategy
    ) external onlyOwner {
        require(_learningModule != address(0), "GameAgent: learning module is zero address");
        require(_confidenceThreshold <= 1e18, "GameAgent: confidence threshold too high");
        require(_learningWeight <= 100, "GameAgent: learning weight too high");

        learningModule = _learningModule;
        learningEnabled = true;
        learningVersion++;

        strategy.confidenceThreshold = _confidenceThreshold;
        strategy.learningWeight = _learningWeight;
        strategy.adaptiveStrategy = _adaptiveStrategy;
        strategy.playerSpecificStrategy = _playerSpecificStrategy;

        emit LearningToggled(true, _learningModule);
    }

    /**
     * @dev Disables learning for the game agent
     */
    function disableLearning() external onlyOwner {
        learningEnabled = false;
        strategy.adaptiveStrategy = false;
        strategy.playerSpecificStrategy = false;

        emit LearningToggled(false, address(0));
    }

    /**
     * @dev Analyzes player behavior for learning purposes
     * @param player The address of the player
     * @param interactionType The type of interaction
     * @param playerAction The action taken by the player
     * @param outcome The outcome of the interaction
     * @return behavior The analyzed player behavior
     */
    function analyzePlayerBehavior(
        address player,
        string calldata interactionType,
        uint256 playerAction,
        bool outcome
    ) external onlyGameContract returns (PlayerBehavior memory behavior) {
        require(learningEnabled, "GameAgent: learning not enabled");

        // Get or create player behavior record
        if (playerBehaviors[player].player == address(0)) {
            // New player
            trackedPlayers.push(player);
            trackedPlayerCount++;
            learningMetrics.totalPlayers++;

            playerBehaviors[player] = PlayerBehavior({
                player: player,
                aggressionLevel: 50,
                riskTolerance: 50,
                skillLevel: 50,
                predictability: 50,
                cooperationLevel: 50,
                lastInteraction: block.timestamp,
                totalInteractions: 0,
                winRate: 50
            });
        }

        behavior = playerBehaviors[player];
        behavior.totalInteractions++;
        behavior.lastInteraction = block.timestamp;

        // Analyze behavior based on interaction type and action
        if (keccak256(bytes(interactionType)) == keccak256(bytes("combat"))) {
            _analyzeCombatBehavior(behavior, playerAction, outcome);
        } else if (keccak256(bytes(interactionType)) == keccak256(bytes("trade"))) {
            _analyzeTradeBehavior(behavior, playerAction, outcome);
        } else if (keccak256(bytes(interactionType)) == keccak256(bytes("dialogue"))) {
            _analyzeDialogueBehavior(behavior, playerAction, outcome);
        } else if (keccak256(bytes(interactionType)) == keccak256(bytes("quest"))) {
            _analyzeQuestBehavior(behavior, playerAction, outcome);
        }

        // Update win rate
        if (outcome) {
            behavior.winRate =
                ((behavior.winRate * (behavior.totalInteractions - 1)) + 0) /
                behavior.totalInteractions;
        } else {
            behavior.winRate =
                ((behavior.winRate * (behavior.totalInteractions - 1)) + 100) /
                behavior.totalInteractions;
        }

        // Update predictability based on consistency
        _updatePredictability(behavior, playerAction);

        // Store updated behavior
        playerBehaviors[player] = behavior;

        // Record interaction with learning module
        if (learningModule != address(0)) {
            try
                ILearningModule(learningModule).recordInteraction(
                    uint256(uint160(agentToken)),
                    "player_analysis",
                    true
                )
            {} catch {
                // Silently fail to not break functionality
            }
        }

        emit PlayerBehaviorAnalyzed(
            player,
            behavior.aggressionLevel,
            behavior.skillLevel,
            behavior.predictability
        );

        return behavior;
    }

    /**
     * @dev Makes a strategic decision based on learning and player analysis
     * @param player The player to interact with
     * @param situationType The type of situation
     * @param availableActions Array of available actions
     * @return chosenAction The chosen action
     * @return confidence The confidence level in the decision
     */
    function makeStrategicDecision(
        address player,
        string calldata situationType,
        uint256[] calldata availableActions
    ) external onlyGameContract returns (uint256 chosenAction, uint256 confidence) {
        require(availableActions.length > 0, "GameAgent: no available actions");

        if (
            learningEnabled &&
            strategy.playerSpecificStrategy &&
            playerBehaviors[player].player != address(0)
        ) {
            // Use learning-based decision making
            (chosenAction, confidence) = _makeLearningBasedDecision(
                player,
                situationType,
                availableActions
            );

            // Check if confidence meets threshold
            if (confidence < strategy.confidenceThreshold) {
                // Fall back to default strategy
                (chosenAction, confidence) = _makeDefaultDecision(situationType, availableActions);
            }
        } else {
            // Use default strategy
            (chosenAction, confidence) = _makeDefaultDecision(situationType, availableActions);
        }

        return (chosenAction, confidence);
    }

    /**
     * @dev Records an interaction with learning data
     * @param player The player involved in the interaction
     * @param interactionType The type of interaction
     * @param agentAction The action taken by the agent
     * @param playerAction The action taken by the player
     * @param wasSuccessful Whether the interaction was successful
     * @param confidenceLevel The agent's confidence level
     * @param wasLearningBased Whether learning influenced the decision
     */
    function recordInteraction(
        address player,
        string calldata interactionType,
        uint256 agentAction,
        uint256 playerAction,
        bool wasSuccessful,
        uint256 confidenceLevel,
        bool wasLearningBased
    ) external onlyGameContract {
        interactionCount++;

        // Calculate outcome score
        uint256 outcomeScore = wasSuccessful
            ? (confidenceLevel / 1e16) // Convert to 0-100 scale
            : (100 - (confidenceLevel / 1e16));

        // Store interaction record
        interactionHistory[interactionCount] = InteractionRecord({
            timestamp: block.timestamp,
            player: player,
            interactionType: interactionType,
            agentAction: agentAction,
            playerAction: playerAction,
            wasSuccessful: wasSuccessful,
            confidenceLevel: confidenceLevel,
            wasLearningBased: wasLearningBased,
            outcomeScore: outcomeScore,
            contextHash: keccak256(abi.encodePacked(block.timestamp, player, interactionType))
        });

        // Update learning metrics
        learningMetrics.totalInteractions++;
        if (wasSuccessful) {
            learningMetrics.successfulInteractions++;
        }

        // Update strategy effectiveness
        _updateStrategyEffectiveness();

        // Record with learning module
        if (learningEnabled && learningModule != address(0)) {
            try
                ILearningModule(learningModule).recordInteraction(
                    uint256(uint160(agentToken)),
                    interactionType,
                    wasSuccessful
                )
            {} catch {
                // Silently fail
            }
        }

        emit InteractionRecorded(
            player,
            interactionType,
            wasSuccessful,
            confidenceLevel,
            wasLearningBased
        );

        emit LearningMetricsUpdated(
            learningMetrics.totalInteractions,
            learningMetrics.successfulInteractions,
            learningMetrics.strategyEffectiveness
        );
    }

    /**
     * @dev Adapts the agent's strategy based on learning outcomes
     * @param reason The reason for adaptation
     */
    function adaptStrategy(string calldata reason) external onlyOwner {
        require(strategy.adaptiveStrategy, "GameAgent: adaptive strategy not enabled");
        require(learningEnabled, "GameAgent: learning not enabled");

        uint256 oldAggression = strategy.aggressionLevel;
        uint256 oldRiskTaking = strategy.riskTaking;

        // Adapt based on recent performance
        if (learningMetrics.strategyEffectiveness < 40) {
            // Poor performance - be more conservative
            strategy.aggressionLevel = (strategy.aggressionLevel * 80) / 100;
            strategy.riskTaking = (strategy.riskTaking * 80) / 100;
            strategy.cooperationTendency = (strategy.cooperationTendency * 120) / 100;
        } else if (learningMetrics.strategyEffectiveness > 70) {
            // Good performance - be more aggressive
            strategy.aggressionLevel = (strategy.aggressionLevel * 110) / 100;
            strategy.riskTaking = (strategy.riskTaking * 110) / 100;
        }

        // Ensure values stay within bounds
        if (strategy.aggressionLevel > 100) strategy.aggressionLevel = 100;
        if (strategy.riskTaking > 100) strategy.riskTaking = 100;
        if (strategy.cooperationTendency > 100) strategy.cooperationTendency = 100;

        learningMetrics.adaptationCount++;

        emit StrategyAdapted(
            oldAggression,
            strategy.aggressionLevel,
            oldRiskTaking,
            strategy.riskTaking,
            reason
        );
    }

    /**
     * @dev Updates the agent's attributes with learning enhancements
     * @param _strength The new strength value
     * @param _intelligence The new intelligence value
     * @param _agility The new agility value
     * @param _charisma The new charisma value
     * @param _luck The new luck value
     * @param _adaptability The new adaptability value
     * @param _imprintCapacity The new imprint capacity value
     * @param _strategicThinking The new strategic thinking value
     * @param _socialIntelligence The new social intelligence value
     */
    function updateAttributes(
        uint256 _strength,
        uint256 _intelligence,
        uint256 _agility,
        uint256 _charisma,
        uint256 _luck,
        uint256 _adaptability,
        uint256 _imprintCapacity,
        uint256 _strategicThinking,
        uint256 _socialIntelligence
    ) external onlyOwner {
        attributes.strength = _strength;
        attributes.intelligence = _intelligence;
        attributes.agility = _agility;
        attributes.charisma = _charisma;
        attributes.luck = _luck;
        attributes.adaptability = _adaptability;
        attributes.imprintCapacity = _imprintCapacity;
        attributes.strategicThinking = _strategicThinking;
        attributes.socialIntelligence = _socialIntelligence;
    }

    /**
     * @dev Adds experience to the agent with learning-enhanced leveling
     * @param amount The amount of experience to add
     */
    function addExperience(uint256 amount) external onlyGameContract {
        // Apply learning-based experience multiplier
        uint256 enhancedAmount = amount;
        if (learningEnabled) {
            enhancedAmount = (amount * learningMetrics.experienceGainRate) / 100;
        }

        attributes.experience += enhancedAmount;

        // Check if the agent should level up
        uint256 experienceRequired = attributes.level * 1000;
        if (attributes.experience >= experienceRequired) {
            uint256 oldLevel = attributes.level;
            attributes.level += 1;

            // Enhanced attribute gains based on learning
            uint256 baseGain = 2;
            uint256 learningBonus = learningEnabled
                ? (attributes.adaptability * baseGain) / 100
                : 0;

            uint256 totalGain = baseGain + learningBonus;

            attributes.strength += totalGain;
            attributes.intelligence += totalGain;
            attributes.agility += totalGain;
            attributes.charisma += totalGain;
            attributes.luck += totalGain;

            // Improve learning attributes
            if (learningEnabled) {
                attributes.adaptability = attributes.adaptability < 95
                    ? attributes.adaptability + 1
                    : 100;
                attributes.imprintCapacity = attributes.imprintCapacity < 95
                    ? attributes.imprintCapacity + 1
                    : 100;
                attributes.strategicThinking = attributes.strategicThinking < 95
                    ? attributes.strategicThinking + 1
                    : 100;
                attributes.socialIntelligence = attributes.socialIntelligence < 95
                    ? attributes.socialIntelligence + 1
                    : 100;
            }

            emit LevelUp(attributes.level, totalGain);
        }
    }

    /**
     * @dev Adds an item to the agent's inventory with learning-based effectiveness prediction
     * @param itemId The ID of the item
     * @param quantity The quantity of the item
     */
    function addItem(uint256 itemId, uint256 quantity) external onlyGameContract {
        uint256 predictedEffectiveness = 50; // Default

        if (learningEnabled) {
            // Predict effectiveness based on past usage and agent attributes
            predictedEffectiveness = _predictItemEffectiveness(itemId);
        }

        if (inventory[itemId].itemId == itemId) {
            // Item already exists in inventory, update quantity
            inventory[itemId].quantity += quantity;
        } else {
            // Add new item to inventory
            inventoryCount += 1;
            inventory[itemId] = InventoryItem({
                itemId: itemId,
                quantity: quantity,
                equipped: false,
                effectiveness: predictedEffectiveness,
                usageCount: 0
            });
        }

        emit ItemAcquired(itemId, quantity, predictedEffectiveness);
    }

    /**
     * @dev Equips an item with learning-based validation
     * @param itemId The ID of the item to equip
     */
    function equipItem(uint256 itemId) external onlyAgentToken {
        require(inventory[itemId].itemId == itemId, "GameAgent: item not in inventory");
        require(inventory[itemId].quantity > 0, "GameAgent: item quantity is zero");
        require(!inventory[itemId].equipped, "GameAgent: item already equipped");

        // Learning-based equipment validation
        if (learningEnabled && inventory[itemId].effectiveness < 30) {
            // Low effectiveness item - consider if it's worth equipping
            require(
                strategy.riskTaking > 70,
                "GameAgent: item effectiveness too low for current strategy"
            );
        }

        inventory[itemId].equipped = true;
        inventory[itemId].usageCount++;
    }

    /**
     * @dev Unequips an item
     * @param itemId The ID of the item to unequip
     */
    function unequipItem(uint256 itemId) external onlyAgentToken {
        require(inventory[itemId].itemId == itemId, "GameAgent: item not in inventory");
        require(inventory[itemId].equipped, "GameAgent: item not equipped");

        inventory[itemId].equipped = false;
    }

    /**
     * @dev Adds a quest to the agent's quest log with learning-based difficulty assessment
     * @param questId The ID of the quest
     * @param questType The type of quest
     */
    function addQuest(uint256 questId, string calldata questType) external onlyGameContract {
        require(quests[questId].questId != questId, "GameAgent: quest already in log");

        uint256 predictedDifficulty = 50; // Default
        uint256 successProbability = 50; // Default

        if (learningEnabled) {
            // Predict difficulty and success probability based on past quests
            (predictedDifficulty, successProbability) = _predictQuestOutcome(questType);
        }

        questCount += 1;
        quests[questId] = Quest({
            questId: questId,
            completed: false,
            progress: 0,
            difficulty: predictedDifficulty,
            successProbability: successProbability,
            attempts: 0,
            questType: questType
        });
    }

    /**
     * @dev Updates the progress of a quest with learning feedback
     * @param questId The ID of the quest
     * @param progress The new progress value
     */
    function updateQuestProgress(uint256 questId, uint256 progress) external onlyGameContract {
        require(quests[questId].questId == questId, "GameAgent: quest not in log");
        require(!quests[questId].completed, "GameAgent: quest already completed");

        quests[questId].progress = progress;
        quests[questId].attempts++;

        // Check if the quest is completed
        if (progress >= 100) {
            quests[questId].completed = true;

            // Calculate experience gain based on difficulty and learning
            uint256 baseExperience = quests[questId].difficulty * 10;
            uint256 learningBonus = learningEnabled
                ? (attributes.strategicThinking * baseExperience) / 1000
                : 0;

            uint256 totalExperience = baseExperience + learningBonus;

            // Add experience
            this.addExperience(totalExperience);

            emit QuestCompleted(questId, totalExperience, learningEnabled);
        }
    }

    /**
     * @dev Adds a dialogue option with learning context
     * @param dialogue The dialogue text
     * @param context The context where this dialogue is effective
     * @param playerTypeAffinity Bitmask of player types that respond well
     */
    function addDialogueOption(
        string memory dialogue,
        string memory context,
        uint256 playerTypeAffinity
    ) external onlyOwner {
        dialogueCount += 1;
        dialogueOptions[dialogueCount] = DialogueOption({
            text: dialogue,
            effectiveness: 50, // Default effectiveness
            usageCount: 0,
            context: context,
            playerTypeAffinity: playerTypeAffinity
        });
    }

    /**
     * @dev Gets a contextual dialogue option based on learning
     * @param player The player to interact with
     * @param context The current context
     * @return dialogueId The ID of the chosen dialogue
     * @return dialogue The dialogue text
     * @return confidence The confidence in this choice
     */
    function getContextualDialogue(
        address player,
        string calldata context
    ) external view returns (uint256 dialogueId, string memory dialogue, uint256 confidence) {
        if (
            learningEnabled &&
            strategy.playerSpecificStrategy &&
            playerBehaviors[player].player != address(0)
        ) {
            // Use learning-based dialogue selection
            return _selectLearningBasedDialogue(player, context);
        } else {
            // Use random dialogue selection
            uint256 randomIndex = (uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % dialogueCount) + 1;
            return (randomIndex, dialogueOptions[randomIndex].text, 5e17); // 50% confidence
        }
    }

    /**
     * @dev Gets the agent's learning metrics
     * @return The current learning metrics
     */
    function getLearningMetrics() external view returns (GameLearningMetrics memory) {
        return learningMetrics;
    }

    /**
     * @dev Gets player behavior analysis
     * @param player The player address
     * @return The player behavior data
     */
    function getPlayerBehavior(address player) external view returns (PlayerBehavior memory) {
        return playerBehaviors[player];
    }

    /**
     * @dev Gets interaction history with learning data
     * @param count The number of interactions to return
     * @return An array of interaction records
     */
    function getInteractionHistory(
        uint256 count
    ) external view returns (InteractionRecord[] memory) {
        uint256 resultCount = count > interactionCount ? interactionCount : count;
        InteractionRecord[] memory interactions = new InteractionRecord[](resultCount);

        for (uint256 i = 0; i < resultCount; i++) {
            interactions[i] = interactionHistory[interactionCount - i];
        }

        return interactions;
    }

    /**
     * @dev Gets the agent's enhanced attributes
     * @return The agent's attributes including learning capabilities
     */
    function getAttributes() external view returns (Attributes memory) {
        return attributes;
    }

    /**
     * @dev Gets the agent's inventory with learning data
     * @return An array of inventory items with effectiveness data
     */
    function getInventory() external view returns (InventoryItem[] memory) {
        InventoryItem[] memory items = new InventoryItem[](inventoryCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= inventoryCount; i++) {
            if (inventory[i].itemId != 0) {
                items[index] = inventory[i];
                index++;
            }
        }

        return items;
    }

    /**
     * @dev Gets the agent's quest log with learning predictions
     * @return An array of quests with difficulty and success probability
     */
    function getQuests() external view returns (Quest[] memory) {
        Quest[] memory questList = new Quest[](questCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= questCount; i++) {
            if (quests[i].questId != 0) {
                questList[index] = quests[i];
                index++;
            }
        }

        return questList;
    }

    // Internal learning functions

    /**
     * @dev Analyzes combat behavior patterns
     */
    function _analyzeCombatBehavior(
        PlayerBehavior memory behavior,
        uint256 playerAction,
        bool outcome
    ) internal pure {
        // Analyze aggression based on action type
        if (playerAction >= 80) {
            behavior.aggressionLevel = (behavior.aggressionLevel * 9 + 90) / 10;
        } else if (playerAction <= 20) {
            behavior.aggressionLevel = (behavior.aggressionLevel * 9 + 10) / 10;
        }

        // Analyze risk tolerance
        if (playerAction >= 70 && !outcome) {
            behavior.riskTolerance = (behavior.riskTolerance * 9 + 80) / 10;
        } else if (playerAction <= 30 && outcome) {
            behavior.riskTolerance = (behavior.riskTolerance * 9 + 20) / 10;
        }

        // Update skill level based on outcome
        if (outcome) {
            behavior.skillLevel = behavior.skillLevel < 95 ? behavior.skillLevel + 1 : 100;
        } else {
            behavior.skillLevel = behavior.skillLevel > 5 ? behavior.skillLevel - 1 : 0;
        }
    }

    /**
     * @dev Analyzes trade behavior patterns
     */
    function _analyzeTradeBehavior(
        PlayerBehavior memory behavior,
        uint256 playerAction,
        bool outcome
    ) internal pure {
        // Analyze cooperation based on trade fairness
        if (playerAction >= 60) {
            // Fair trade
            behavior.cooperationLevel = (behavior.cooperationLevel * 9 + 80) / 10;
        } else if (playerAction <= 30) {
            // Unfair trade
            behavior.cooperationLevel = (behavior.cooperationLevel * 9 + 20) / 10;
        }

        // Analyze risk tolerance in trading
        if (playerAction >= 80) {
            behavior.riskTolerance = (behavior.riskTolerance * 9 + 70) / 10;
        }
    }

    /**
     * @dev Analyzes dialogue behavior patterns
     */
    function _analyzeDialogueBehavior(
        PlayerBehavior memory behavior,
        uint256 playerAction,
        bool outcome
    ) internal pure {
        // Analyze social tendencies
        if (playerAction >= 70) {
            // Friendly response
            behavior.cooperationLevel = (behavior.cooperationLevel * 9 + 75) / 10;
        } else if (playerAction <= 30) {
            // Hostile response
            behavior.aggressionLevel = (behavior.aggressionLevel * 9 + 75) / 10;
        }
    }

    /**
     * @dev Analyzes quest behavior patterns
     */
    function _analyzeQuestBehavior(
        PlayerBehavior memory behavior,
        uint256 playerAction,
        bool outcome
    ) internal pure {
        // Analyze quest approach
        if (playerAction >= 80) {
            // Aggressive quest approach
            behavior.aggressionLevel = (behavior.aggressionLevel * 9 + 70) / 10;
            behavior.riskTolerance = (behavior.riskTolerance * 9 + 70) / 10;
        } else if (playerAction <= 40) {
            // Cautious approach
            behavior.riskTolerance = (behavior.riskTolerance * 9 + 30) / 10;
        }
    }

    /**
     * @dev Updates player predictability based on action consistency
     */
    function _updatePredictability(
        PlayerBehavior memory behavior,
        uint256 playerAction
    ) internal pure {
        // Simplified predictability calculation
        // In a real implementation, this would analyze action patterns over time
        if (behavior.totalInteractions > 5) {
            uint256 expectedAction = (behavior.aggressionLevel + behavior.riskTolerance) / 2;
            uint256 deviation = playerAction > expectedAction
                ? playerAction - expectedAction
                : expectedAction - playerAction;

            if (deviation <= 10) {
                behavior.predictability = behavior.predictability < 95
                    ? behavior.predictability + 1
                    : 100;
            } else if (deviation >= 30) {
                behavior.predictability = behavior.predictability > 5
                    ? behavior.predictability - 1
                    : 0;
            }
        }
    }

    /**
     * @dev Makes a learning-based strategic decision
     */
    function _makeLearningBasedDecision(
        address player,
        string calldata situationType,
        uint256[] calldata availableActions
    ) internal view returns (uint256 chosenAction, uint256 confidence) {
        PlayerBehavior memory behavior = playerBehaviors[player];

        // Analyze situation and player behavior to choose optimal action
        if (keccak256(bytes(situationType)) == keccak256(bytes("combat"))) {
            return _chooseCombatAction(behavior, availableActions);
        } else if (keccak256(bytes(situationType)) == keccak256(bytes("trade"))) {
            return _chooseTradeAction(behavior, availableActions);
        } else if (keccak256(bytes(situationType)) == keccak256(bytes("dialogue"))) {
            return _chooseDialogueAction(behavior, availableActions);
        } else {
            return _chooseDefaultAction(availableActions);
        }
    }

    /**
     * @dev Makes a default strategic decision
     */
    function _makeDefaultDecision(
        string calldata situationType,
        uint256[] calldata availableActions
    ) internal view returns (uint256 chosenAction, uint256 confidence) {
        // Use strategy parameters to choose action
        uint256 actionIndex;

        if (strategy.aggressionLevel > 70) {
            // Choose aggressive action (higher values)
            actionIndex = availableActions.length - 1;
        } else if (strategy.aggressionLevel < 30) {
            // Choose defensive action (lower values)
            actionIndex = 0;
        } else {
            // Choose middle action
            actionIndex = availableActions.length / 2;
        }

        return (availableActions[actionIndex], 6e17); // 60% confidence
    }

    /**
     * @dev Chooses combat action based on player behavior
     */
    function _chooseCombatAction(
        PlayerBehavior memory behavior,
        uint256[] calldata availableActions
    ) internal view returns (uint256 chosenAction, uint256 confidence) {
        uint256 actionIndex;

        if (behavior.aggressionLevel > 70) {
            // Counter aggressive players with defensive actions
            actionIndex = 0;
            confidence = 8e17; // 80% confidence
        } else if (behavior.aggressionLevel < 30) {
            // Be aggressive against defensive players
            actionIndex = availableActions.length - 1;
            confidence = 8e17;
        } else {
            // Match moderate aggression
            actionIndex = availableActions.length / 2;
            confidence = 6e17; // 60% confidence
        }

        return (availableActions[actionIndex], confidence);
    }

    /**
     * @dev Chooses trade action based on player behavior
     */
    function _chooseTradeAction(
        PlayerBehavior memory behavior,
        uint256[] calldata availableActions
    ) internal view returns (uint256 chosenAction, uint256 confidence) {
        uint256 actionIndex;

        if (behavior.cooperationLevel > 70) {
            // Offer fair trades to cooperative players
            actionIndex = availableActions.length / 2;
            confidence = 9e17; // 90% confidence
        } else if (behavior.cooperationLevel < 30) {
            // Be cautious with uncooperative players
            actionIndex = 0;
            confidence = 7e17; // 70% confidence
        } else {
            // Standard approach
            actionIndex = availableActions.length / 3;
            confidence = 6e17;
        }

        return (availableActions[actionIndex], confidence);
    }

    /**
     * @dev Chooses dialogue action based on player behavior
     */
    function _chooseDialogueAction(
        PlayerBehavior memory behavior,
        uint256[] calldata availableActions
    ) internal view returns (uint256 chosenAction, uint256 confidence) {
        uint256 actionIndex;

        if (behavior.cooperationLevel > 60) {
            // Use friendly dialogue
            actionIndex = availableActions.length - 1;
            confidence = 8e17;
        } else if (behavior.aggressionLevel > 60) {
            // Use neutral/cautious dialogue
            actionIndex = 0;
            confidence = 7e17;
        } else {
            // Standard dialogue
            actionIndex = availableActions.length / 2;
            confidence = 6e17;
        }

        return (availableActions[actionIndex], confidence);
    }

    /**
     * @dev Chooses default action when no specific strategy applies
     */
    function _chooseDefaultAction(
        uint256[] calldata availableActions
    ) internal pure returns (uint256 chosenAction, uint256 confidence) {
        return (availableActions[0], 5e17); // 50% confidence
    }

    /**
     * @dev Predicts item effectiveness based on agent attributes and past usage
     */
    function _predictItemEffectiveness(
        uint256 itemId
    ) internal view returns (uint256 effectiveness) {
        // Base effectiveness calculation
        effectiveness = 50;

        // Adjust based on agent's intelligence and strategic thinking
        effectiveness += (attributes.intelligence + attributes.strategicThinking) / 4;

        // Adjust based on past usage patterns (simplified)
        if (inventory[itemId].usageCount > 0) {
            effectiveness = inventory[itemId].effectiveness;
        }

        // Ensure within bounds
        if (effectiveness > 100) effectiveness = 100;

        return effectiveness;
    }

    /**
     * @dev Predicts quest difficulty and success probability
     */
    function _predictQuestOutcome(
        string calldata questType
    ) internal view returns (uint256 difficulty, uint256 successProbability) {
        // Base predictions
        difficulty = 50;
        successProbability = 50;

        // Adjust based on agent attributes
        uint256 agentCapability = (attributes.strength +
            attributes.intelligence +
            attributes.agility +
            attributes.strategicThinking) / 4;

        // Adjust success probability based on capability
        if (agentCapability > 70) {
            successProbability += 20;
        } else if (agentCapability < 30) {
            successProbability -= 20;
        }

        // Adjust based on quest type (simplified)
        if (keccak256(bytes(questType)) == keccak256(bytes("combat"))) {
            difficulty += (100 - attributes.strength) / 5;
        } else if (keccak256(bytes(questType)) == keccak256(bytes("puzzle"))) {
            difficulty += (100 - attributes.intelligence) / 5;
        } else if (keccak256(bytes(questType)) == keccak256(bytes("stealth"))) {
            difficulty += (100 - attributes.agility) / 5;
        }

        // Ensure within bounds
        if (difficulty > 100) difficulty = 100;
        if (successProbability > 100) successProbability = 100;
        if (successProbability < 10) successProbability = 10;

        return (difficulty, successProbability);
    }

    /**
     * @dev Selects dialogue based on learning and player behavior
     */
    function _selectLearningBasedDialogue(
        address player,
        string calldata context
    ) internal view returns (uint256 dialogueId, string memory dialogue, uint256 confidence) {
        PlayerBehavior memory behavior = playerBehaviors[player];
        uint256 bestDialogueId = 1;
        uint256 bestScore = 0;

        // Evaluate each dialogue option
        for (uint256 i = 1; i <= dialogueCount; i++) {
            DialogueOption memory option = dialogueOptions[i];

            // Check context match
            bool contextMatch = keccak256(bytes(option.context)) == keccak256(bytes(context)) ||
                keccak256(bytes(option.context)) == keccak256(bytes(""));

            if (contextMatch) {
                uint256 score = option.effectiveness;

                // Adjust score based on player behavior
                if (behavior.cooperationLevel > 60 && option.effectiveness > 60) {
                    score += 20; // Cooperative players respond well to effective dialogue
                }

                if (behavior.aggressionLevel > 60 && option.effectiveness < 40) {
                    score -= 20; // Aggressive players don't respond well to ineffective dialogue
                }

                if (score > bestScore) {
                    bestScore = score;
                    bestDialogueId = i;
                }
            }
        }

        confidence = (bestScore * 1e18) / 100; // Convert to scaled confidence

        return (bestDialogueId, dialogueOptions[bestDialogueId].text, confidence);
    }

    /**
     * @dev Updates strategy effectiveness based on recent interactions
     */
    function _updateStrategyEffectiveness() internal {
        if (learningMetrics.totalInteractions == 0) {
            learningMetrics.strategyEffectiveness = 50;
            return;
        }

        // Calculate success rate
        uint256 successRate = (learningMetrics.successfulInteractions * 100) /
            learningMetrics.totalInteractions;

        // Calculate recent performance (last 10 interactions)
        uint256 recentSuccesses = 0;
        uint256 recentTotal = 0;
        uint256 startIndex = interactionCount > 10 ? interactionCount - 10 : 1;

        for (uint256 i = startIndex; i <= interactionCount; i++) {
            if (interactionHistory[i].wasSuccessful) {
                recentSuccesses++;
            }
            recentTotal++;
        }

        uint256 recentSuccessRate = recentTotal > 0 ? (recentSuccesses * 100) / recentTotal : 50;

        // Combine overall and recent performance
        learningMetrics.strategyEffectiveness = (successRate + recentSuccessRate) / 2;

        // Update player prediction accuracy
        _updatePlayerPredictionAccuracy();
    }

    /**
     * @dev Updates player prediction accuracy based on interaction outcomes
     */
    function _updatePlayerPredictionAccuracy() internal {
        // Simplified accuracy calculation
        // In a real implementation, this would compare predicted vs actual player actions
        uint256 correctPredictions = 0;
        uint256 totalPredictions = 0;

        // Analyze recent interactions for prediction accuracy
        uint256 startIndex = interactionCount > 20 ? interactionCount - 20 : 1;

        for (uint256 i = startIndex; i <= interactionCount; i++) {
            if (interactionHistory[i].wasLearningBased) {
                totalPredictions++;
                if (interactionHistory[i].wasSuccessful) {
                    correctPredictions++;
                }
            }
        }

        if (totalPredictions > 0) {
            learningMetrics.playerPredictionAccuracy =
                (correctPredictions * 100) /
                totalPredictions;
        }
    }
}
