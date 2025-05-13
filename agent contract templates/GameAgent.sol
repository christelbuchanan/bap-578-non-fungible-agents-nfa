// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title GameAgent
 * @dev Template for game agents that can interact with players and evolve over time
 */
contract GameAgent is Ownable {
    using Strings for uint256;
    
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The address of the game contract
    address public gameContract;
    
    // The agent's attributes
    struct Attributes {
        uint256 strength;
        uint256 intelligence;
        uint256 agility;
        uint256 charisma;
        uint256 luck;
        uint256 experience;
        uint256 level;
    }
    
    // The agent's attributes
    Attributes public attributes;
    
    // The agent's inventory
    struct InventoryItem {
        uint256 itemId;
        uint256 quantity;
        bool equipped;
    }
    
    // The agent's inventory
    mapping(uint256 => InventoryItem) public inventory;
    uint256 public inventoryCount;
    
    // The agent's quest log
    struct Quest {
        uint256 questId;
        bool completed;
        uint256 progress;
    }
    
    // The agent's quest log
    mapping(uint256 => Quest) public quests;
    uint256 public questCount;
    
    // The agent's dialogue options
    mapping(uint256 => string) public dialogueOptions;
    uint256 public dialogueCount;
    
    // Event emitted when the agent levels up
    event LevelUp(uint256 newLevel);
    
    // Event emitted when the agent completes a quest
    event QuestCompleted(uint256 questId);
    
    // Event emitted when the agent acquires an item
    event ItemAcquired(uint256 itemId, uint256 quantity);
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _gameContract The address of the game contract
     */
    constructor(
        address _agentToken,
        address _gameContract
    ) {
        require(_agentToken != address(0), "GameAgent: agent token is zero address");
        require(_gameContract != address(0), "GameAgent: game contract is zero address");
        
        agentToken = _agentToken;
        gameContract = _gameContract;
        
        // Initialize attributes
        attributes = Attributes({
            strength: 10,
            intelligence: 10,
            agility: 10,
            charisma: 10,
            luck: 10,
            experience: 0,
            level: 1
        });
        
        // Initialize dialogue options
        dialogueOptions[1] = "Greetings, adventurer!";
        dialogueOptions[2] = "I have a quest for you.";
        dialogueOptions[3] = "Would you like to trade?";
        dialogueCount = 3;
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
     * @dev Updates the agent's attributes
     * @param _strength The new strength value
     * @param _intelligence The new intelligence value
     * @param _agility The new agility value
     * @param _charisma The new charisma value
     * @param _luck The new luck value
     */
    function updateAttributes(
        uint256 _strength,
        uint256 _intelligence,
        uint256 _agility,
        uint256 _charisma,
        uint256 _luck
    ) 
        external 
        onlyOwner 
    {
        attributes.strength = _strength;
        attributes.intelligence = _intelligence;
        attributes.agility = _agility;
        attributes.charisma = _charisma;
        attributes.luck = _luck;
    }
    
    /**
     * @dev Adds experience to the agent
     * @param amount The amount of experience to add
     */
    function addExperience(uint256 amount) 
        external 
        onlyGameContract 
    {
        attributes.experience += amount;
        
        // Check if the agent should level up
        uint256 experienceRequired = attributes.level * 1000;
        if (attributes.experience >= experienceRequired) {
            attributes.level += 1;
            
            // Increase attributes on level up
            attributes.strength += 2;
            attributes.intelligence += 2;
            attributes.agility += 2;
            attributes.charisma += 2;
            attributes.luck += 2;
            
            emit LevelUp(attributes.level);
        }
    }
    
    /**
     * @dev Adds an item to the agent's inventory
     * @param itemId The ID of the item
     * @param quantity The quantity of the item
     */
    function addItem(uint256 itemId, uint256 quantity) 
        external 
        onlyGameContract 
    {
        if (inventory[itemId].itemId == itemId) {
            // Item already exists in inventory, update quantity
            inventory[itemId].quantity += quantity;
        } else {
            // Add new item to inventory
            inventoryCount += 1;
            inventory[itemId] = InventoryItem({
                itemId: itemId,
                quantity: quantity,
                equipped: false
            });
        }
        
        emit ItemAcquired(itemId, quantity);
    }
    
    /**
     * @dev Equips an item
     * @param itemId The ID of the item to equip
     */
    function equipItem(uint256 itemId) 
        external 
        onlyAgentToken 
    {
        require(inventory[itemId].itemId == itemId, "GameAgent: item not in inventory");
        require(inventory[itemId].quantity > 0, "GameAgent: item quantity is zero");
        require(!inventory[itemId].equipped, "GameAgent: item already equipped");
        
        inventory[itemId].equipped = true;
    }
    
    /**
     * @dev Unequips an item
     * @param itemId The ID of the item to unequip
     */
    function unequipItem(uint256 itemId) 
        external 
        onlyAgentToken 
    {
        require(inventory[itemId].itemId == itemId, "GameAgent: item not in inventory");
        require(inventory[itemId].equipped, "GameAgent: item not equipped");
        
        inventory[itemId].equipped = false;
    }
    
    /**
     * @dev Adds a quest to the agent's quest log
     * @param questId The ID of the quest
     */
    function addQuest(uint256 questId) 
        external 
        onlyGameContract 
    {
        require(quests[questId].questId != questId, "GameAgent: quest already in log");
        
        questCount += 1;
        quests[questId] = Quest({
            questId: questId,
            completed: false,
            progress: 0
        });
    }
    
    /**
     * @dev Updates the progress of a quest
     * @param questId The ID of the quest
     * @param progress The new progress value
     */
    function updateQuestProgress(uint256 questId, uint256 progress) 
        external 
        onlyGameContract 
    {
        require(quests[questId].questId == questId, "GameAgent: quest not in log");
        require(!quests[questId].completed, "GameAgent: quest already completed");
        
        quests[questId].progress = progress;
        
        // Check if the quest is completed
        if (progress >= 100) {
            quests[questId].completed = true;
            emit QuestCompleted(questId);
        }
    }
    
    /**
     * @dev Adds a dialogue option
     * @param dialogue The dialogue text
     */
    function addDialogueOption(string memory dialogue) 
        external 
        onlyOwner 
    {
        dialogueCount += 1;
        dialogueOptions[dialogueCount] = dialogue;
    }
    
    /**
     * @dev Gets a random dialogue option
     * @return The dialogue text
     */
    function getRandomDialogue() 
        external 
        view 
        returns (string memory) 
    {
        // Use a pseudo-random number based on block data
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % dialogueCount + 1;
        return dialogueOptions[randomIndex];
    }
    
    /**
     * @dev Gets the agent's attributes
     * @return The agent's attributes
     */
    function getAttributes() 
        external 
        view 
        returns (Attributes memory) 
    {
        return attributes;
    }
    
    /**
     * @dev Gets the agent's inventory
     * @return An array of inventory items
     */
    function getInventory() 
        external 
        view 
        returns (InventoryItem[] memory) 
    {
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
     * @dev Gets the agent's quest log
     * @return An array of quests
     */
    function getQuests() 
        external 
        view 
        returns (Quest[] memory) 
    {
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
}
