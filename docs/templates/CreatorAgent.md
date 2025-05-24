# Creator Agent

## Overview
The Creator Agent is a specialized BEP007 agent template designed to serve as a personalized brand assistant or digital twin for content creators. It helps creators manage their content, audience segments, and publishing schedule while optionally learning and evolving based on creator preferences and audience interactions.

## Architecture Paths

### 🚀 **Path 1: Simple Creator Agent (Default)**
- **Perfect for**: Most content creators getting started
- **Benefits**: Immediate deployment, familiar JSON metadata
- **Learning**: Static persona and content preferences
- **Gas Cost**: Minimal (standard ERC721 operations)

### 🧠 **Path 2: Learning Creator Agent (Advanced)**
- **Perfect for**: Creators wanting AI that evolves with their brand
- **Benefits**: Learns audience preferences, content performance, optimal timing
- **Learning**: Dynamic adaptation based on engagement metrics
- **Gas Cost**: Optimized (only learning roots stored on-chain)

## Features

### Core Features (Both Paths)
- **Creator Profile Management**: Store and update creator information including name, bio, niche, social handles, content style, and voice style
- **Content Library**: Manage a library of content items with different types, titles, summaries, and URIs
- **Audience Segmentation**: Create and manage audience segments with specific interests and communication styles
- **Content Scheduling**: Schedule content for publication to specific audience segments
- **Automated Publishing**: Automatically publish scheduled content when the scheduled time is reached

### Enhanced Learning Features (Path 2 Only)
- **Audience Preference Learning**: Learns what content resonates with different audience segments
- **Optimal Timing Discovery**: Identifies best posting times based on engagement patterns
- **Content Performance Analysis**: Tracks which content types perform best for specific audiences
- **Voice Evolution**: Adapts communication style based on successful interactions
- **Cross-Platform Optimization**: Learns platform-specific content strategies
- **Trend Adaptation**: Identifies and adapts to emerging content trends

## Key Functions

### Profile Management
- `updateProfile`: Update the creator's profile information
- `getProfile`: Retrieve the creator's profile information
- `updateLearningPreferences` (Learning agents only): Configure learning parameters

### Content Management
- `addContent`: Add a new content item to the library
- `updateContent`: Update an existing content item
- `getFeaturedContent`: Get featured content items
- `getContentForSegment`: Get content items for a specific audience segment
- `analyzeContentPerformance` (Learning agents only): Get AI-driven content insights

### Audience Management
- `createAudienceSegment`: Create a new audience segment
- `getContentForSegment`: Get content items for a specific audience segment
- `updateSegmentPreferences` (Learning agents only): Update learned audience preferences

### Content Scheduling
- `scheduleContent`: Schedule content for publication
- `publishScheduledContent`: Publish scheduled content
- `getUpcomingContent`: Get upcoming scheduled content
- `optimizeScheduling` (Learning agents only): Get AI-suggested optimal posting times

### Learning Functions (Path 2 Only)
- `recordEngagement`: Record audience engagement metrics for learning
- `getLearningInsights`: Get current learning insights and recommendations
- `updateLearningTree`: Update the agent's learning state with new data
- `verifyLearningClaim`: Verify specific learning achievements

## Implementation Examples

### Simple Creator Agent (Path 1)

```javascript
// Basic creator agent setup
const creatorMetadata = {
  persona: "Tech content creator focused on blockchain education",
  memory: "Specializes in making complex topics accessible",
  voiceHash: "",
  animationURI: "",
  vaultURI: "ipfs://Qm.../creator-vault.json",
  vaultHash: ethers.utils.keccak256("vault_content"),
  // Learning disabled by default
  learningEnabled: false,
  learningModule: ethers.constants.AddressZero,
  learningTreeRoot: ethers.constants.HashZero,
  learningVersion: 0
};

const tx = await bep007Enhanced.createAgent(
  creatorAddress,
  creatorLogicAddress,
  "ipfs://creator-metadata.json",
  creatorMetadata
);
```

### Learning Creator Agent (Path 2)

```javascript
// Advanced learning creator agent
const learningCreatorMetadata = {
  persona: "AI-powered tech educator that adapts to audience preferences",
  memory: "Learns optimal content strategies and audience engagement patterns",
  voiceHash: "bafkreigh2akiscaild...",
  animationURI: "ipfs://Qm.../creator-avatar.mp4",
  vaultURI: "ipfs://Qm.../learning-vault.json",
  vaultHash: ethers.utils.keccak256("learning_vault_content"),
  // Learning enabled from day 1
  learningEnabled: true,
  learningModule: merkleTreeLearning.address,
  learningTreeRoot: initialCreatorLearningRoot,
  learningVersion: 1
};

const tx = await bep007Enhanced.createAgent(
  creatorAddress,
  creatorLogicAddress,
  "ipfs://learning-creator-metadata.json",
  learningCreatorMetadata
);
```

## Learning Tree Structure (Path 2)

```json
{
  "root": "0x...",
  "branches": {
    "audiencePreferences": {
      "techEnthusiasts": {
        "preferredContentTypes": ["tutorials", "deep-dives"],
        "optimalPostingTimes": ["9AM", "2PM", "7PM"],
        "engagementPatterns": {
          "avgWatchTime": "8.5min",
          "completionRate": 0.73,
          "shareRate": 0.12
        },
        "confidence": 0.87
      },
      "beginners": {
        "preferredContentTypes": ["explainers", "quick-tips"],
        "optimalPostingTimes": ["12PM", "6PM"],
        "engagementPatterns": {
          "avgWatchTime": "4.2min",
          "completionRate": 0.89,
          "shareRate": 0.08
        },
        "confidence": 0.92
      }
    },
    "contentPerformance": {
      "tutorials": {
        "avgEngagement": 0.15,
        "bestPerformingTopics": ["DeFi basics", "Smart contracts"],
        "optimalLength": "10-15min",
        "confidence": 0.81
      },
      "quickTips": {
        "avgEngagement": 0.23,
        "bestPerformingTopics": ["Security tips", "Tool recommendations"],
        "optimalLength": "2-3min",
        "confidence": 0.94
      }
    },
    "platformOptimization": {
      "youtube": {
        "bestThumbnailStyle": "bright-colors-with-text",
        "optimalTitleLength": "45-60chars",
        "bestUploadTimes": ["2PM-4PM"],
        "confidence": 0.76
      },
      "twitter": {
        "bestHashtagCount": "2-3",
        "optimalThreadLength": "5-7tweets",
        "bestPostTimes": ["9AM", "1PM", "7PM"],
        "confidence": 0.88
      }
    },
    "voiceEvolution": {
      "toneAdaptation": {
        "technical": "detailed-but-accessible",
        "casual": "friendly-expert",
        "educational": "patient-encouraging"
      },
      "languagePatterns": {
        "successfulPhrases": ["Let's break this down", "Here's the key insight"],
        "avoidedPhrases": ["Obviously", "Simply put"],
        "confidence": 0.79
      }
    }
  },
  "metrics": {
    "totalInteractions": 1247,
    "learningEvents": 89,
    "lastUpdated": "2025-01-20T10:00:00Z",
    "learningVelocity": 0.18,
    "overallConfidence": 0.85
  }
}
```

## Use Cases

### Simple Creator Agent (Path 1)
1. **Content Calendar Management**: Schedule posts across platforms
2. **Audience Organization**: Segment followers by interests
3. **Brand Consistency**: Maintain consistent voice and messaging
4. **Content Library**: Organize and categorize all created content

### Learning Creator Agent (Path 2)
1. **Adaptive Content Strategy**: AI learns what content performs best
2. **Audience Intelligence**: Discovers hidden audience preferences
3. **Optimal Timing**: Learns best posting times for maximum engagement
4. **Performance Optimization**: Continuously improves content strategy
5. **Cross-Platform Learning**: Adapts strategies for different platforms
6. **Trend Detection**: Identifies emerging topics and opportunities

## Learning Milestones (Path 2)

The learning creator agent tracks various milestones:

- **100 Content Posts**: Basic content pattern recognition
- **500 Audience Interactions**: Audience preference mapping
- **1000 Engagements**: Advanced optimization recommendations
- **80% Confidence Score**: Reliable strategy suggestions
- **95% Confidence Score**: Expert-level content optimization

## Migration Path

### Upgrading Simple to Learning Agent

```javascript
// Enable learning on existing simple creator agent
await bep007Enhanced.enableLearning(
  creatorTokenId,
  merkleTreeLearning.address,
  initialCreatorLearningRoot
);

// Start recording interactions for learning
await creatorAgent.recordEngagement(
  "video_tutorial",
  {
    views: 1500,
    likes: 120,
    shares: 25,
    comments: 18,
    watchTime: "7.2min"
  }
);
```

## Integration Points

### Standard Integrations (Both Paths)
- Integrates with the BEP007 token standard for agent ownership and control
- Can be extended to connect with social media platforms for direct posting
- Compatible with content management systems for importing/exporting content

### Learning Integrations (Path 2 Only)
- Analytics platforms for engagement data import
- AI recommendation engines for content suggestions
- Cross-creator learning networks for industry insights
- Performance tracking dashboards with learning visualizations

## Security Considerations

### Standard Security (Both Paths)
- Only the agent owner can update the profile and add content
- Only the agent token can trigger the publication of scheduled content
- Content scheduling requires future timestamps to prevent accidental immediate publication

### Learning Security (Path 2 Only)
- Learning updates are rate-limited (max 50 per day)
- All learning claims are cryptographically verifiable via Merkle proofs
- Learning data integrity protected by on-chain hash verification
- Authorized updaters can be delegated for learning data management

## Getting Started

### For Simple Creator Agent
1. Deploy using standard BEP007 creation pattern
2. Configure creator profile and content preferences
3. Set up audience segments and content calendar
4. Begin publishing and managing content

### For Learning Creator Agent
1. Deploy MerkleTreeLearning contract
2. Create agent with learning enabled from day 1
3. Configure initial learning parameters
4. Begin recording engagement data for learning
5. Monitor learning insights and adapt strategy

### Upgrading Path
1. Start with simple creator agent for immediate functionality
2. Gather engagement data and define learning goals
3. Enable learning when ready for advanced features
4. Gradually integrate AI recommendations into content strategy

The Creator Agent template provides a complete solution for content creators at any technical level, with a clear upgrade path from simple automation to advanced AI-powered content optimization.
