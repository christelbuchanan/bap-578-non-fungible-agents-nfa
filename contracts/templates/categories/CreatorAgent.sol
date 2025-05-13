// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title CreatorAgent
 * @dev Template for creator agents that serve as personalized brand assistants or digital twins
 */
contract CreatorAgent is Ownable {
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The creator's profile
    struct CreatorProfile {
        string name;
        string bio;
        string niche;
        string[] socialHandles;
        string contentStyle;
        string voiceStyle;
    }
    
    // The creator's profile
    CreatorProfile public profile;
    
    // The creator's content library
    struct ContentItem {
        uint256 id;
        string contentType; // "post", "article", "video", "audio", etc.
        string title;
        string summary;
        string contentURI;
        uint256 timestamp;
        bool featured;
    }
    
    // The creator's content library
    mapping(uint256 => ContentItem) public contentLibrary;
    uint256 public contentCount;
    
    // The creator's audience segments
    struct AudienceSegment {
        uint256 id;
        string name;
        string description;
        string[] interests;
        string communicationStyle;
    }
    
    // The creator's audience segments
    mapping(uint256 => AudienceSegment) public audienceSegments;
    uint256 public segmentCount;
    
    // The creator's scheduled content
    struct ScheduledContent {
        uint256 id;
        string contentType;
        string title;
        string summary;
        string contentURI;
        uint256 scheduledTime;
        bool published;
        uint256[] targetSegments;
    }
    
    // The creator's scheduled content
    mapping(uint256 => ScheduledContent) public scheduledContent;
    uint256 public scheduledCount;
    
    // Event emitted when content is published
    event ContentPublished(uint256 indexed contentId, string contentType, string title);
    
    // Event emitted when a new audience segment is created
    event AudienceSegmentCreated(uint256 indexed segmentId, string name);
    
    // Event emitted when content is scheduled
    event ContentScheduled(uint256 indexed contentId, uint256 scheduledTime);
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _name The creator's name
     * @param _bio The creator's bio
     * @param _niche The creator's niche
     * @param _socialHandles The creator's social media handles
     * @param _contentStyle The creator's content style
     * @param _voiceStyle The creator's voice style
     */
    constructor(
        address _agentToken,
        string memory _name,
        string memory _bio,
        string memory _niche,
        string[] memory _socialHandles,
        string memory _contentStyle,
        string memory _voiceStyle
    ) {
        require(_agentToken != address(0), "CreatorAgent: agent token is zero address");
        
        agentToken = _agentToken;
        
        profile = CreatorProfile({
            name: _name,
            bio: _bio,
            niche: _niche,
            socialHandles: _socialHandles,
            contentStyle: _contentStyle,
            voiceStyle: _voiceStyle
        });
    }
    
    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "CreatorAgent: caller is not agent token");
        _;
    }
    
    /**
     * @dev Updates the creator's profile
     * @param _name The creator's name
     * @param _bio The creator's bio
     * @param _niche The creator's niche
     * @param _socialHandles The creator's social media handles
     * @param _contentStyle The creator's content style
     * @param _voiceStyle The creator's voice style
     */
    function updateProfile(
        string memory _name,
        string memory _bio,
        string memory _niche,
        string[] memory _socialHandles,
        string memory _contentStyle,
        string memory _voiceStyle
    ) 
        external 
        onlyOwner 
    {
        profile = CreatorProfile({
            name: _name,
            bio: _bio,
            niche: _niche,
            socialHandles: _socialHandles,
            contentStyle: _contentStyle,
            voiceStyle: _voiceStyle
        });
    }
    
    /**
     * @dev Adds a content item to the library
     * @param _contentType The type of content
     * @param _title The title of the content
     * @param _summary The summary of the content
     * @param _contentURI The URI of the content
     * @param _featured Whether the content is featured
     * @return contentId The ID of the new content item
     */
    function addContent(
        string memory _contentType,
        string memory _title,
        string memory _summary,
        string memory _contentURI,
        bool _featured
    ) 
        external 
        onlyOwner 
        returns (uint256 contentId) 
    {
        contentCount += 1;
        contentId = contentCount;
        
        contentLibrary[contentId] = ContentItem({
            id: contentId,
            contentType: _contentType,
            title: _title,
            summary: _summary,
            contentURI: _contentURI,
            timestamp: block.timestamp,
            featured: _featured
        });
        
        emit ContentPublished(contentId, _contentType, _title);
        
        return contentId;
    }
    
    /**
     * @dev Updates a content item in the library
     * @param _contentId The ID of the content item
     * @param _title The title of the content
     * @param _summary The summary of the content
     * @param _contentURI The URI of the content
     * @param _featured Whether the content is featured
     */
    function updateContent(
        uint256 _contentId,
        string memory _title,
        string memory _summary,
        string memory _contentURI,
        bool _featured
    ) 
        external 
        onlyOwner 
    {
        require(_contentId <= contentCount && _contentId > 0, "CreatorAgent: content does not exist");
        
        ContentItem storage content = contentLibrary[_contentId];
        
        content.title = _title;
        content.summary = _summary;
        content.contentURI = _contentURI;
        content.featured = _featured;
    }
    
    /**
     * @dev Creates a new audience segment
     * @param _name The name of the segment
     * @param _description The description of the segment
     * @param _interests The interests of the segment
     * @param _communicationStyle The communication style for the segment
     * @return segmentId The ID of the new segment
     */
    function createAudienceSegment(
        string memory _name,
        string memory _description,
        string[] memory _interests,
        string memory _communicationStyle
    ) 
        external 
        onlyOwner 
        returns (uint256 segmentId) 
    {
        segmentCount += 1;
        segmentId = segmentCount;
        
        audienceSegments[segmentId] = AudienceSegment({
            id: segmentId,
            name: _name,
            description: _description,
            interests: _interests,
            communicationStyle: _communicationStyle
        });
        
        emit AudienceSegmentCreated(segmentId, _name);
        
        return segmentId;
    }
    
    /**
     * @dev Schedules content for publication
     * @param _contentType The type of content
     * @param _title The title of the content
     * @param _summary The summary of the content
     * @param _contentURI The URI of the content
     * @param _scheduledTime The time to publish the content
     * @param _targetSegments The target audience segments
     * @return scheduleId The ID of the scheduled content
     */
    function scheduleContent(
        string memory _contentType,
        string memory _title,
        string memory _summary,
        string memory _contentURI,
        uint256 _scheduledTime,
        uint256[] memory _targetSegments
    ) 
        external 
        onlyOwner 
        returns (uint256 scheduleId) 
    {
        require(_scheduledTime > block.timestamp, "CreatorAgent: scheduled time must be in the future");
        
        scheduledCount += 1;
        scheduleId = scheduledCount;
        
        scheduledContent[scheduleId] = ScheduledContent({
            id: scheduleId,
            contentType: _contentType,
            title: _title,
            summary: _summary,
            contentURI: _contentURI,
            scheduledTime: _scheduledTime,
            published: false,
            targetSegments: _targetSegments
        });
        
        emit ContentScheduled(scheduleId, _scheduledTime);
        
        return scheduleId;
    }
    
    /**
     * @dev Publishes scheduled content
     * @param _scheduleId The ID of the scheduled content
     */
    function publishScheduledContent(uint256 _scheduleId) 
        external 
        onlyAgentToken 
    {
        require(_scheduleId <= scheduledCount && _scheduleId > 0, "CreatorAgent: scheduled content does not exist");
        
        ScheduledContent storage content = scheduledContent[_scheduleId];
        require(!content.published, "CreatorAgent: content already published");
        require(block.timestamp >= content.scheduledTime, "CreatorAgent: scheduled time not reached");
        
        content.published = true;
        
        // Add to content library
        contentCount += 1;
        uint256 contentId = contentCount;
        
        contentLibrary[contentId] = ContentItem({
            id: contentId,
            contentType: content.contentType,
            title: content.title,
            summary: content.summary,
            contentURI: content.contentURI,
            timestamp: block.timestamp,
            featured: false
        });
        
        emit ContentPublished(contentId, content.contentType, content.title);
    }
    
    /**
     * @dev Gets the creator's profile
     * @return The creator's profile
     */
    function getProfile() 
        external 
        view 
        returns (CreatorProfile memory) 
    {
        return profile;
    }
    
    /**
     * @dev Gets the featured content
     * @return An array of featured content items
     */
    function getFeaturedContent() 
        external 
        view 
        returns (ContentItem[] memory) 
    {
        // Count featured content
        uint256 featuredCount = 0;
        for (uint256 i = 1; i <= contentCount; i++) {
            if (contentLibrary[i].featured) {
                featuredCount++;
            }
        }
        
        // Create array of featured content
        ContentItem[] memory featured = new ContentItem[](featuredCount);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= contentCount; i++) {
            if (contentLibrary[i].featured) {
                featured[index] = contentLibrary[i];
                index++;
            }
        }
        
        return featured;
    }
    
    /**
     * @dev Gets the content for a specific audience segment
     * @param _segmentId The ID of the audience segment
     * @return An array of content items for the segment
     */
    function getContentForSegment(uint256 _segmentId) 
        external 
        view 
        returns (ContentItem[] memory) 
    {
        require(_segmentId <= segmentCount && _segmentId > 0, "CreatorAgent: segment does not exist");
        
        // Count content for segment
        uint256 segmentContentCount = 0;
        for (uint256 i = 1; i <= scheduledCount; i++) {
            ScheduledContent storage scheduled = scheduledContent[i];
            if (scheduled.published) {
                for (uint256 j = 0; j < scheduled.targetSegments.length; j++) {
                    if (scheduled.targetSegments[j] == _segmentId) {
                        segmentContentCount++;
                        break;
                    }
                }
            }
        }
        
        // Create array of content for segment
        ContentItem[] memory segmentContent = new ContentItem[](segmentContentCount);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= contentCount; i++) {
            for (uint256 j = 1; j <= scheduledCount; j++) {
                ScheduledContent storage scheduled = scheduledContent[j];
                if (scheduled.published && contentLibrary[i].timestamp == scheduled.scheduledTime) {
                    for (uint256 k = 0; k < scheduled.targetSegments.length; k++) {
                        if (scheduled.targetSegments[k] == _segmentId) {
                            segmentContent[index] = contentLibrary[i];
                            index++;
                            break;
                        }
                    }
                }
            }
        }
        
        return segmentContent;
    }
    
    /**
     * @dev Gets the upcoming scheduled content
     * @return An array of upcoming scheduled content
     */
    function getUpcomingContent() 
        external 
        view 
        returns (ScheduledContent[] memory) 
    {
        // Count upcoming content
        uint256 upcomingCount = 0;
        for (uint256 i = 1; i <= scheduledCount; i++) {
            if (!scheduledContent[i].published && scheduledContent[i].scheduledTime > block.timestamp) {
                upcomingCount++;
            }
        }
        
        // Create array of upcoming content
        ScheduledContent[] memory upcoming = new ScheduledContent[](upcomingCount);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= scheduledCount; i++) {
            if (!scheduledContent[i].published && scheduledContent[i].scheduledTime > block.timestamp) {
                upcoming[index] = scheduledContent[i];
                index++;
            }
        }
        
        return upcoming;
    }
}
