// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FanCollectibleAgent
 * @dev Template for fan collectible agents that represent anime/game characters with AI conversation
 */
contract FanCollectibleAgent is Ownable {
    using Strings for uint256;
    
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The character's profile
    struct CharacterProfile {
        string name;
        string universe;
        string backstory;
        string personality;
        string[] catchphrases;
        string[] abilities;
    }
    
    // The character's profile
    CharacterProfile public profile;
    
    // The character's dialogue options
    struct DialogueOption {
        uint256 id;
        string context;
        string[] responses;
        uint256[] nextDialogueIds;
    }
    
    // The character's dialogue options
    mapping(uint256 => DialogueOption) public dialogueOptions;
    uint256 public dialogueCount;
    
    // The character's relationships
    struct Relationship {
        uint256 id;
        address otherCharacter;
        string relationshipType; // "friend", "enemy", "rival", etc.
        string description;
        int256 affinity; // -100 to 100
    }
    
    // The character's relationships
    mapping(uint256 => Relationship) public relationships;
    uint256 public relationshipCount;
    
    // The character's collectible items
    struct CollectibleItem {
        uint256 id;
        string name;
        string description;
        string rarity; // "common", "rare", "legendary", etc.
        string itemType; // "weapon", "armor", "accessory", etc.
        string imageURI;
    }
    
    // The character's collectible items
    mapping(uint256 => CollectibleItem) public collectibleItems;
    uint256 public itemCount;
    
    // The character's story arcs
    struct StoryArc {
        uint256 id;
        string title;
        string description;
        uint256[] dialogueSequence;
        bool completed;
    }
    
    // The character's story arcs
    mapping(uint256 => StoryArc) public storyArcs;
    uint256 public storyArcCount;
    
    // Event emitted when a dialogue is completed
    event DialogueCompleted(uint256 indexed dialogueId, address user);
    
    // Event emitted when a relationship is updated
    event RelationshipUpdated(uint256 indexed relationshipId, int256 newAffinity);
    
    // Event emitted when a story arc is completed
    event StoryArcCompleted(uint256 indexed storyArcId);
    
    // Event emitted when a collectible item is awarded
    event ItemAwarded(uint256 indexed itemId, address recipient);
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _name The character's name
     * @param _universe The character's universe
     * @param _backstory The character's backstory
     * @param _personality The character's personality
     * @param _catchphrases The character's catchphrases
     * @param _abilities The character's abilities
     */
    constructor(
        address _agentToken,
        string memory _name,
        string memory _universe,
        string memory _backstory,
        string memory _personality,
        string[] memory _catchphrases,
        string[] memory _abilities
    ) {
        require(_agentToken != address(0), "FanCollectibleAgent: agent token is zero address");
        
        agentToken = _agentToken;
        
        profile = CharacterProfile({
            name: _name,
            universe: _universe,
            backstory: _backstory,
            personality: _personality,
            catchphrases: _catchphrases,
            abilities: _abilities
        });
    }
    
    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "FanCollectibleAgent: caller is not agent token");
        _;
    }
    
    /**
     * @dev Updates the character's profile
     * @param _name The character's name
     * @param _universe The character's universe
     * @param _backstory The character's backstory
     * @param _personality The character's personality
     * @param _catchphrases The character's catchphrases
     * @param _abilities The character's abilities
     */
    function updateProfile(
        string memory _name,
        string memory _universe,
        string memory _backstory,
        string memory _personality,
        string[] memory _catchphrases,
        string[] memory _abilities
    ) 
        external 
        onlyOwner 
    {
        profile = CharacterProfile({
            name: _name,
            universe: _universe,
            backstory: _backstory,
            personality: _personality,
            catchphrases: _catchphrases,
            abilities: _abilities
        });
    }
    
    /**
     * @dev Adds a dialogue option
     * @param _context The context of the dialogue
     * @param _responses The possible responses
     * @param _nextDialogueIds The next dialogue IDs for each response
     * @return dialogueId The ID of the new dialogue option
     */
    function addDialogueOption(
        string memory _context,
        string[] memory _responses,
        uint256[] memory _nextDialogueIds
    ) 
        external 
        onlyOwner 
        returns (uint256 dialogueId) 
    {
        require(_responses.length == _nextDialogueIds.length, "FanCollectibleAgent: responses and next dialogue IDs must have same length");
        
        dialogueCount += 1;
        dialogueId = dialogueCount;
        
        dialogueOptions[dialogueId] = DialogueOption({
            id: dialogueId,
            context: _context,
            responses: _responses,
            nextDialogueIds: _nextDialogueIds
        });
        
        return dialogueId;
    }
    
    /**
     * @dev Adds a relationship
     * @param _otherCharacter The address of the other character
     * @param _relationshipType The type of relationship
     * @param _description The description of the relationship
     * @param _affinity The affinity level
     * @return relationshipId The ID of the new relationship
     */
    function addRelationship(
        address _otherCharacter,
        string memory _relationshipType,
        string memory _description,
        int256 _affinity
    ) 
        external 
        onlyOwner 
        returns (uint256 relationshipId) 
    {
        require(_otherCharacter != address(0), "FanCollectibleAgent: other character is zero address");
        require(_affinity >= -100 && _affinity <= 100, "FanCollectibleAgent: affinity must be between -100 and 100");
        
        relationshipCount += 1;
        relationshipId = relationshipCount;
        
        relationships[relationshipId] = Relationship({
            id: relationshipId,
            otherCharacter: _otherCharacter,
            relationshipType: _relationshipType,
            description: _description,
            affinity: _affinity
        });
        
        return relationshipId;
    }
    
    /**
     * @dev Updates a relationship's affinity
     * @param _relationshipId The ID of the relationship
     * @param _affinityChange The change in affinity
     */
    function updateRelationshipAffinity(
        uint256 _relationshipId,
        int256 _affinityChange
    ) 
        external 
        onlyAgentToken 
    {
        require(_relationshipId <= relationshipCount && _relationshipId > 0, "FanCollectibleAgent: relationship does not exist");
        
        Relationship storage relationship = relationships[_relationshipId];
        
        // Update affinity, ensuring it stays within bounds
        int256 newAffinity = relationship.affinity + _affinityChange;
        if (newAffinity > 100) {
            newAffinity = 100;
        } else if (newAffinity < -100) {
            newAffinity = -100;
        }
        
        relationship.affinity = newAffinity;
        
        emit RelationshipUpdated(_relationshipId, newAffinity);
    }
    
    /**
     * @dev Adds a collectible item
     * @param _name The name of the item
     * @param _description The description of the item
     * @param _rarity The rarity of the item
     * @param _itemType The type of the item
     * @param _imageURI The image URI of the item
     * @return itemId The ID of the new item
     */
    function addCollectibleItem(
        string memory _name,
        string memory _description,
        string memory _rarity,
        string memory _itemType,
        string memory _imageURI
    ) 
        external 
        onlyOwner 
        returns (uint256 itemId) 
    {
        itemCount += 1;
        itemId = itemCount;
        
        collectibleItems[itemId] = CollectibleItem({
            id: itemId,
            name: _name,
            description: _description,
            rarity: _rarity,
            itemType: _itemType,
            imageURI: _imageURI
        });
        
        return itemId;
    }
    
    /**
     * @dev Awards a collectible item to a user
     * @param _itemId The ID of the item
     * @param _recipient The address of the recipient
     */
    function awardItem(
        uint256 _itemId,
        address _recipient
    ) 
        external 
        onlyAgentToken 
    {
        require(_itemId <= itemCount && _itemId > 0, "FanCollectibleAgent: item does not exist");
        require(_recipient != address(0), "FanCollectibleAgent: recipient is zero address");
        
        emit ItemAwarded(_itemId, _recipient);
    }
    
    /**
     * @dev Adds a story arc
     * @param _title The title of the story arc
     * @param _description The description of the story arc
     * @param _dialogueSequence The sequence of dialogues in the story arc
     * @return storyArcId The ID of the new story arc
     */
    function addStoryArc(
        string memory _title,
        string memory _description,
        uint256[] memory _dialogueSequence
    ) 
        external 
        onlyOwner 
        returns (uint256 storyArcId) 
    {
        require(_dialogueSequence.length > 0, "FanCollectibleAgent: dialogue sequence cannot be empty");
        
        storyArcCount += 1;
        storyArcId = storyArcCount;
        
        storyArcs[storyArcId] = StoryArc({
            id: storyArcId,
            title: _title,
            description: _description,
            dialogueSequence: _dialogueSequence,
            completed: false
        });
        
        return storyArcId;
    }
    
    /**
     * @dev Completes a dialogue
     * @param _dialogueId The ID of the dialogue
     * @param _responseIndex The index of the response chosen
     * @return nextDialogueId The ID of the next dialogue
     */
    function completeDialogue(
        uint256 _dialogueId,
        uint256 _responseIndex
    ) 
        external 
        onlyAgentToken 
        returns (uint256 nextDialogueId) 
    {
        require(_dialogueId <= dialogueCount && _dialogueId > 0, "FanCollectibleAgent: dialogue does not exist");
        
        DialogueOption storage dialogue = dialogueOptions[_dialogueId];
        require(_responseIndex < dialogue.responses.length, "FanCollectibleAgent: response index out of bounds");
        
        emit DialogueCompleted(_dialogueId, tx.origin);
        
        return dialogue.nextDialogueIds[_responseIndex];
    }
    
    /**
     * @dev Completes a story arc
     * @param _storyArcId The ID of the story arc
     */
    function completeStoryArc(uint256 _storyArcId) 
        external 
        onlyAgentToken 
    {
        require(_storyArcId <= storyArcCount && _storyArcId > 0, "FanCollectibleAgent: story arc does not exist");
        
        StoryArc storage storyArc = storyArcs[_storyArcId];
        require(!storyArc.completed, "FanCollectibleAgent: story arc already completed");
        
        storyArc.completed = true;
        
        emit StoryArcCompleted(_storyArcId);
    }
    
    /**
     * @dev Gets the character's profile
     * @return The character's profile
     */
    function getProfile() 
        external 
        view 
        returns (CharacterProfile memory) 
    {
        return profile;
    }
    
    /**
     * @dev Gets a dialogue option
     * @param _dialogueId The ID of the dialogue option
     * @return The dialogue option
     */
    function getDialogueOption(uint256 _dialogueId) 
        external 
        view 
        returns (DialogueOption memory) 
    {
        require(_dialogueId <= dialogueCount && _dialogueId > 0, "FanCollectibleAgent: dialogue does not exist");
        return dialogueOptions[_dialogueId];
    }
    
    /**
     * @dev Gets a random catchphrase
     * @return The catchphrase
     */
    function getRandomCatchphrase() 
        external 
        view 
        returns (string memory) 
    {
        if (profile.catchphrases.length == 0) {
            return "";
        }
        
        // Use a pseudo-random number based on block data
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % profile.catchphrases.length;
        return profile.catchphrases[randomIndex];
    }
    
    /**
     * @dev Gets the active story arcs
     * @return An array of active story arcs
     */
    function getActiveStoryArcs() 
        external 
        view 
        returns (StoryArc[] memory) 
    {
        // Count active story arcs
        uint256 activeCount = 0;
        for (uint256 i = 1; i <= storyArcCount; i++) {
            if (!storyArcs[i].completed) {
                activeCount++;
            }
        }
        
        StoryArc[] memory active = new StoryArc[](activeCount);
        
        // Fill array with active story arcs
        uint256 index = 0;
        for (uint256 i = 1; i <= storyArcCount; i++) {
            if (!storyArcs[i].completed) {
                active[index] = storyArcs[i];
                index++;
            }
        }
        
        return active;
    }
    
    /**
     * @dev Gets the collectible items by rarity
     * @param _rarity The rarity to filter by
     * @return An array of collectible items with the specified rarity
     */
    function getItemsByRarity(string memory _rarity) 
        external 
        view 
        returns (CollectibleItem[] memory) 
    {
        // Count items with the specified rarity
        uint256 rarityCount = 0;
        for (uint256 i = 1; i <= itemCount; i++) {
            if (keccak256(bytes(collectibleItems[i].rarity)) == keccak256(bytes(_rarity))) {
                rarityCount++;
            }
        }
        
        CollectibleItem[] memory items = new CollectibleItem[](rarityCount);
        
        // Fill array with items of the specified rarity
        uint256 index = 0;
        for (uint256 i = 1; i <= itemCount; i++) {
            if (keccak256(bytes(collectibleItems[i].rarity)) == keccak256(bytes(_rarity))) {
                items[index] = collectibleItems[i];
                index++;
            }
        }
        
        return items;
    }
    
    /**
     * @dev Gets the relationships by type
     * @param _relationshipType The relationship type to filter by
     * @return An array of relationships with the specified type
     */
    function getRelationshipsByType(string memory _relationshipType) 
        external 
        view 
        returns (Relationship[] memory) 
    {
        // Count relationships with the specified type
        uint256 typeCount = 0;
        for (uint256 i = 1; i <= relationshipCount; i++) {
            if (keccak256(bytes(relationships[i].relationshipType)) == keccak256(bytes(_relationshipType))) {
                typeCount++;
            }
        }
        
        Relationship[] memory filteredRelationships = new Relationship[](typeCount);
        
        // Fill array with relationships of the specified type
        uint256 index = 0;
        for (uint256 i = 1; i <= relationshipCount; i++) {
            if (keccak256(bytes(relationships[i].relationshipType)) == keccak256(bytes(_relationshipType))) {
                filteredRelationships[index] = relationships[i];
                index++;
            }
        }
        
        return filteredRelationships;
    }
}
