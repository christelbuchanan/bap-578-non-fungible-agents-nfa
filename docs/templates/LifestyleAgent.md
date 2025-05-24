# Lifestyle Agent

## Overview
The Lifestyle Agent is a specialized BEP007 agent template designed to handle travel planning, scheduling, reminders, and task management. It serves as a personal assistant to help users organize and manage their daily lives, with optional learning capabilities to become more effective and personalized over time.

## Architecture Paths

### 🚀 **Path 1: Standard Lifestyle Agent (Default)**
- **Perfect for**: Most users needing immediate personal assistant functionality
- **Benefits**: Instant deployment, reliable scheduling, consistent task management
- **Learning**: Static preferences and fixed organizational patterns
- **Gas Cost**: Minimal (standard ERC721 operations)

### 🧠 **Path 2: Learning Lifestyle Agent (Advanced)**
- **Perfect for**: Users wanting AI that adapts to their lifestyle patterns
- **Benefits**: Learns user habits, optimizes schedules, predicts needs, personalizes recommendations
- **Learning**: Dynamic adaptation based on user behavior and preferences
- **Gas Cost**: Optimized (only learning roots stored on-chain)

## Features

### Core Features (Both Paths)
- **Preference Management**: Store and update user preferences for travel, diet, work schedule, and leisure activities
- **Calendar Management**: Create, track, and complete calendar events and reminders
- **Travel Planning**: Create and manage travel plans with destinations, accommodations, and activities
- **Task Management**: Create, prioritize, and complete tasks
- **Automated Reminders**: Trigger reminders at scheduled times

### Enhanced Learning Features (Path 2 Only)
- **Habit Recognition**: Learns user daily routines and patterns
- **Predictive Scheduling**: Suggests optimal times for tasks and events
- **Preference Evolution**: Adapts to changing user preferences over time
- **Productivity Optimization**: Identifies and suggests productivity improvements
- **Travel Intelligence**: Learns travel preferences and suggests personalized itineraries
- **Wellness Tracking**: Monitors and suggests improvements to work-life balance

## Key Functions

### Preference Management
- `updatePreferences`: Update the user's preferences
- `getPreferences`: Retrieve the user's preferences
- `learnPreferences` (Learning agents only): Automatically adapt preferences based on user behavior

### Calendar Management
- `createCalendarEvent`: Create a new calendar event
- `completeCalendarEvent`: Mark a calendar event as completed
- `getUpcomingEvents`: Get upcoming calendar events
- `getPendingReminders`: Get pending reminders
- `optimizeSchedule` (Learning agents only): Suggest schedule optimizations based on learned patterns

### Travel Planning
- `createTravelPlan`: Create a new travel plan
- `confirmTravelPlan`: Confirm a travel plan
- `getUpcomingTravelPlans`: Get upcoming travel plans
- `personalizeTravel` (Learning agents only): Generate personalized travel recommendations

### Task Management
- `createTask`: Create a new task
- `completeTask`: Mark a task as completed
- `getPendingTasks`: Get pending tasks
- `prioritizeTasks` (Learning agents only): Automatically prioritize tasks based on learned patterns

### Reminder System
- `triggerReminder`: Trigger a reminder
- `getPendingReminders`: Get pending reminders
- `predictiveReminders` (Learning agents only): Suggest reminders based on learned habits

### Learning Functions (Path 2 Only)
- `recordUserBehavior`: Record user activity patterns for learning
- `getLearningInsights`: Get current lifestyle optimization insights
- `updateLifestyleLearning`: Update learned habits and preferences
- `verifyProductivityGains`: Verify specific productivity improvements

## Implementation Examples

### Standard Lifestyle Agent (Path 1)

```javascript
// Basic lifestyle agent setup
const lifestyleMetadata = {
  persona: "Organized personal assistant focused on schedule and task management",
  memory: "Maintains user preferences and scheduled events consistently",
  voiceHash: "",
  animationURI: "",
  vaultURI: "ipfs://Qm.../lifestyle-vault.json",
  vaultHash: ethers.utils.keccak256("lifestyle_vault_content"),
  // Learning disabled by default
  learningEnabled: false,
  learningModule: ethers.constants.AddressZero,
  learningTreeRoot: ethers.constants.HashZero,
  learningVersion: 0
};

const tx = await bep007Enhanced.createAgent(
  userAddress,
  lifestyleLogicAddress,
  "ipfs://lifestyle-metadata.json",
  lifestyleMetadata
);
```

### Learning Lifestyle Agent (Path 2)

```javascript
// Advanced learning lifestyle agent
const learningLifestyleMetadata = {
  persona: "AI-powered personal assistant that learns and adapts to user lifestyle patterns",
  memory: "Learns user habits, preferences, and productivity patterns for optimal assistance",
  voiceHash: "bafkreilife2akiscaild...",
  animationURI: "ipfs://Qm.../lifestyle-avatar.mp4",
  vaultURI: "ipfs://Qm.../learning-lifestyle-vault.json",
  vaultHash: ethers.utils.keccak256("learning_lifestyle_vault_content"),
  // Learning enabled from day 1
  learningEnabled: true,
  learningModule: merkleTreeLearning.address,
  learningTreeRoot: initialLifestyleLearningRoot,
  learningVersion: 1
};

const tx = await bep007Enhanced.createAgent(
  userAddress,
  lifestyleLogicAddress,
  "ipfs://learning-lifestyle-metadata.json",
  learningLifestyleMetadata
);
```

## Learning Tree Structure (Path 2)

```json
{
  "root": "0x...",
  "branches": {
    "dailyRoutines": {
      "morningRoutine": {
        "wakeUpTime": { avg: "7:15AM", variance: "±20min", confidence: 0.89 },
        "activities": ["coffee", "news", "exercise"],
        "duration": { avg: "90min", optimal: "75min" },
        "productivity": { rating: 0.82, factors: ["good-sleep", "early-start"] }
      },
      "workSchedule": {
        "peakProductivity": ["9AM-11AM", "2PM-4PM"],
        "preferredBreaks": { frequency: "90min", duration: "15min" },
        "meetingPreferences": { maxPerDay: 4, preferredTimes: ["10AM", "2PM"] },
        "confidence": 0.91
      },
      "eveningRoutine": {
        "windDownTime": { avg: "9:30PM", activities: ["reading", "meditation"] },
        "screenTimeLimit": "8PM",
        "sleepTime": { target: "10:30PM", actual: "10:45PM" },
        "confidence": 0.76
      }
    },
    "taskPatterns": {
      "workTasks": {
        "optimalDuration": { focused: "45min", creative: "90min", admin: "30min" },
        "bestTimes": { creative: "morning", focused: "afternoon", admin: "end-of-day" },
        "completionRate": { overall: 0.87, byType: { urgent: 0.95, routine: 0.82 } },
        "confidence": 0.88
      },
      "personalTasks": {
        "preferredDays": { errands: "saturday", planning: "sunday", social: "friday" },
        "batchingPreference": true,
        "procrastinationTriggers": ["complex-tasks", "unclear-requirements"],
        "confidence": 0.79
      }
    },
    "travelPreferences": {
      "destinations": {
        "preferred": { climate: "temperate", culture: "historic", activity: "walking" },
        "avoided": { climate: "extreme-heat", crowds: "very-busy", transport: "long-flights" },
        "confidence": 0.84
      },
      "planning": {
        "leadTime": { domestic: "2weeks", international: "6weeks" },
        "bookingStyle": "research-heavy",
        "budgetAllocation": { accommodation: 0.4, food: 0.3, activities: 0.3 },
        "confidence": 0.82
      },
      "accommodation": {
        "type": "boutique-hotels",
        "location": "city-center-walkable",
        "amenities": ["wifi", "fitness", "quiet"],
        "confidence": 0.87
      }
    },
    "wellnessPatterns": {
      "stressIndicators": {
        "triggers": ["overbooked-calendar", "travel-delays", "tech-issues"],
        "symptoms": ["sleep-disruption", "meal-skipping", "exercise-avoidance"],
        "recovery": ["nature-walks", "meditation", "social-time"],
        "confidence": 0.73
      },
      "energyManagement": {
        "highEnergyTimes": ["morning", "early-afternoon"],
        "lowEnergyTimes": ["post-lunch", "late-evening"],
        "energyBoosters": ["short-walks", "healthy-snacks", "music"],
        "confidence": 0.85
      }
    }
  },
  "metrics": {
    "totalActivities": 2156,
    "habitChanges": 23,
    "productivityGains": 0.18,
    "lastUpdated": "2025-01-20T10:00:00Z",
    "learningVelocity": 0.14,
    "overallConfidence": 0.83
  }
}
```

## Use Cases

### Standard Lifestyle Agent (Path 1)
1. **Personal Assistant**: Manage daily schedule, tasks, and reminders
2. **Travel Companion**: Plan and organize trips with detailed itineraries
3. **Productivity Tool**: Track and prioritize tasks
4. **Event Planner**: Schedule and manage events with automated reminders

### Learning Lifestyle Agent (Path 2)
1. **Adaptive Assistant**: AI that learns and optimizes daily routines
2. **Predictive Planner**: Anticipates needs and suggests optimal scheduling
3. **Wellness Coach**: Monitors patterns and suggests lifestyle improvements
4. **Travel Intelligence**: Learns preferences and creates personalized travel experiences
5. **Productivity Optimizer**: Identifies and eliminates inefficiencies
6. **Habit Tracker**: Monitors and helps build positive habits

## Learning Milestones (Path 2)

The learning lifestyle agent tracks various milestones:

- **100 Scheduled Events**: Basic routine pattern recognition
- **500 Completed Tasks**: Task prioritization optimization
- **30 Days of Data**: Daily routine establishment
- **3 Travel Plans**: Travel preference learning
- **80% Confidence Score**: Reliable lifestyle optimization suggestions

## Migration Path

### Upgrading Standard to Learning Agent

```javascript
// Enable learning on existing standard lifestyle agent
await bep007Enhanced.enableLearning(
  lifestyleTokenId,
  merkleTreeLearning.address,
  initialLifestyleLearningRoot
);

// Start recording user behavior for learning
await lifestyleAgent.recordUserBehavior(
  {
    activityType: "task_completion",
    taskCategory: "work",
    completionTime: "45min",
    timeOfDay: "10:30AM",
    productivityRating: 0.9,
    energyLevel: "high"
  }
);
```

## Integration Points

### Standard Integrations (Both Paths)
- Integrates with the BEP007 token standard for agent ownership and control
- Can connect to calendar systems for event synchronization
- Compatible with notification systems for reminders
- Supports travel booking APIs for itinerary management

### Learning Integrations (Path 2 Only)
- **Wearable Devices**: Import health and activity data for wellness insights
- **Calendar APIs**: Analyze meeting patterns and productivity correlations
- **Travel APIs**: Learn from booking history and preferences
- **Productivity Apps**: Integrate with task management and time tracking tools

## Security Considerations

### Standard Security (Both Paths)
- Only the agent owner can update preferences, create events, and manage tasks
- Only the agent token can trigger reminders
- Time-based validations ensure logical event scheduling
- Recurring events have configurable intervals and end times

### Learning Security (Path 2 Only)
- Behavior learning is rate-limited (max 100 data points per day)
- All learning claims are cryptographically verifiable via Merkle proofs
- Personal data integrity protected by on-chain hash verification
- Privacy controls allow users to limit what data is used for learning

## Lifestyle Categories

### The Busy Professional
- **Standard**: Fixed work schedule and task templates
- **Learning**: Adapts to changing work demands and optimizes productivity
- **Specialization**: Meeting management and deadline tracking

### The Frequent Traveler
- **Standard**: Basic travel planning and itinerary management
- **Learning**: Learns travel preferences and optimizes booking strategies
- **Specialization**: Personalized travel recommendations and logistics

### The Wellness Enthusiast
- **Standard**: Basic health and fitness scheduling
- **Learning**: Tracks wellness patterns and suggests lifestyle improvements
- **Specialization**: Holistic wellness optimization and habit formation

### The Family Organizer
- **Standard**: Family calendar and activity coordination
- **Learning**: Learns family patterns and optimizes scheduling for everyone
- **Specialization**: Multi-person coordination and event planning

## Getting Started

### For Standard Lifestyle Agent
1. Deploy using standard BEP007 creation pattern
2. Configure user preferences and basic schedule
3. Set up recurring tasks and reminders
4. Begin using for daily organization and planning

### For Learning Lifestyle Agent
1. Deploy MerkleTreeLearning contract
2. Create agent with learning enabled from day 1
3. Configure initial lifestyle parameters and privacy settings
4. Begin recording daily activities for pattern learning
5. Monitor insights and adapt recommendations over time

### Upgrading Path
1. Start with standard agent for immediate organization benefits
2. Gather activity data and identify optimization opportunities
3. Enable learning when ready for adaptive assistance
4. Gradually integrate AI recommendations into daily routine

The Lifestyle Agent template provides a complete personal assistant solution, from basic scheduling and task management to sophisticated AI-powered lifestyle optimization that adapts to individual patterns and preferences.
