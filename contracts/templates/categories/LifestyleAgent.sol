// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../interfaces/ILearningModule.sol";

/**
 * @title LifestyleAgent
 * @dev Enhanced template for lifestyle agents that handle travel, scheduling, and reminders with learning capabilities
 */
contract LifestyleAgent is Ownable, ReentrancyGuard {
    using Strings for uint256;
    
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // Learning module integration
    address public learningModule;
    bool public learningEnabled;
    
    // The user's preferences
    struct Preferences {
        string travelPreferences;
        string dietaryRestrictions;
        string workSchedule;
        string leisureActivities;
        string communicationStyle;
        // Learning enhancements
        uint256 adaptabilityLevel; // How much the agent adapts to user behavior
        string[] learningObjectives;
        uint256 proactivityLevel; // How proactive the agent is (0-100)
        uint256 personalizationDepth; // Depth of personalization (0-100)
    }
    
    // The user's preferences
    Preferences public preferences;
    
    // The calendar events
    struct CalendarEvent {
        uint256 id;
        string title;
        string description;
        uint256 startTime;
        uint256 endTime;
        string location;
        bool isRecurring;
        uint256 recurringInterval; // in seconds
        uint256 recurringEndTime;
        bool isReminder;
        bool completed;
        // Learning enhancements
        uint256 userEngagement; // How engaged the user was with this event
        uint256 satisfactionScore; // User satisfaction with the event
        string[] eventTags; // Tags for categorization
        uint256 stressLevel; // Stress level associated with event (0-100)
    }
    
    // The calendar events
    mapping(uint256 => CalendarEvent) public calendarEvents;
    uint256 public eventCount;
    
    // The travel plans
    struct TravelPlan {
        uint256 id;
        string destination;
        uint256 departureTime;
        uint256 returnTime;
        string accommodation;
        string transportation;
        string[] activities;
        bool confirmed;
        // Learning enhancements
        uint256 enjoymentRating; // User enjoyment rating (0-100)
        uint256 budgetEfficiency; // How well the plan stayed within budget
        string[] preferredActivities; // Activities the user enjoyed most
        uint256 stressLevel; // Travel stress level
    }
    
    // The travel plans
    mapping(uint256 => TravelPlan) public travelPlans;
    uint256 public travelPlanCount;
    
    // The task list
    struct Task {
        uint256 id;
        string title;
        string description;
        uint256 dueDate;
        uint256 priority; // 1-5, 5 being highest
        bool completed;
        // Learning enhancements
        uint256 completionTime; // Time taken to complete
        uint256 difficultyRating; // User-rated difficulty
        string[] skillsRequired; // Skills required for this task
        uint256 procrastinationLevel; // How much the user procrastinated
    }
    
    // The task list
    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;
    
    // Learning-specific data structures
    struct UserBehaviorPattern {
        uint256 averageTaskCompletionTime;
        uint256 preferredWorkingHours;
        uint256 procrastinationTendency;
        uint256 stressThreshold;
        string[] productiveEnvironments;
        uint256 lastUpdated;
    }
    
    UserBehaviorPattern public behaviorPattern;
    
    // Lifestyle insights from learning
    struct LifestyleInsights {
        string[] optimalSchedulingTimes;
        uint256[] productivityPeaks;
        string[] stressReductionActivities;
        uint256 workLifeBalance; // 0-100 score
        uint256 lastUpdated;
    }
    
    LifestyleInsights public lifestyleInsights;
    
    // Wellness tracking
    struct WellnessMetrics {
        uint256 averageStressLevel;
        uint256 sleepQuality;
        uint256 exerciseFrequency;
        uint256 socialEngagement;
        uint256 overallWellbeing;
        uint256 lastUpdated;
    }
    
    WellnessMetrics public wellnessMetrics;
    
    // Event emitted when a calendar event is created
    event CalendarEventCreated(uint256 indexed eventId, string title, uint256 startTime);
    
    // Event emitted when a travel plan is created
    event TravelPlanCreated(uint256 indexed planId, string destination, uint256 departureTime);
    
    // Event emitted when a task is created
    event TaskCreated(uint256 indexed taskId, string title, uint256 dueDate);
    
    // Event emitted when a reminder is triggered
    event ReminderTriggered(uint256 indexed eventId, string title);
    
    // Learning-specific events
    event LearningInsightGenerated(string insightType, bytes data, uint256 timestamp);
    event BehaviorPatternUpdated(uint256 timestamp);
    event LifestyleOptimizationSuggested(string suggestion, uint256 timestamp);
    event WellnessMetricsUpdated(uint256 overallWellbeing, uint256 timestamp);
    event ProactiveActionTaken(string actionType, bytes data, uint256 timestamp);
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _travelPreferences The user's travel preferences
     * @param _dietaryRestrictions The user's dietary restrictions
     * @param _workSchedule The user's work schedule
     * @param _leisureActivities The user's leisure activities
     * @param _communicationStyle The user's communication style
     */
    constructor(
        address _agentToken,
        string memory _travelPreferences,
        string memory _dietaryRestrictions,
        string memory _workSchedule,
        string memory _leisureActivities,
        string memory _communicationStyle
    ) {
        require(_agentToken != address(0), "LifestyleAgent: agent token is zero address");
        
        agentToken = _agentToken;
        
        preferences = Preferences({
            travelPreferences: _travelPreferences,
            dietaryRestrictions: _dietaryRestrictions,
            workSchedule: _workSchedule,
            leisureActivities: _leisureActivities,
            communicationStyle: _communicationStyle,
            adaptabilityLevel: 50, // Default medium adaptability
            learningObjectives: new string[](0),
            proactivityLevel: 30, // Default low-medium proactivity
            personalizationDepth: 40 // Default medium personalization
        });
        
        // Initialize behavior pattern
        behaviorPattern = UserBehaviorPattern({
            averageTaskCompletionTime: 0,
            preferredWorkingHours: 9, // Default 9 AM
            procrastinationTendency: 50, // Default medium
            stressThreshold: 70, // Default high threshold
            productiveEnvironments: new string[](0),
            lastUpdated: block.timestamp
        });
        
        // Initialize lifestyle insights
        lifestyleInsights = LifestyleInsights({
            optimalSchedulingTimes: new string[](0),
            productivityPeaks: new uint256[](0),
            stressReductionActivities: new string[](0),
            workLifeBalance: 50, // Default balanced
            lastUpdated: block.timestamp
        });
        
        // Initialize wellness metrics
        wellnessMetrics = WellnessMetrics({
            averageStressLevel: 50,
            sleepQuality: 70,
            exerciseFrequency: 30,
            socialEngagement: 50,
            overallWellbeing: 50,
            lastUpdated: block.timestamp
        });
    }
    
    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "LifestyleAgent: caller is not agent token");
        _;
    }
    
    /**
     * @dev Modifier to check if learning is enabled
     */
    modifier whenLearningEnabled() {
        require(learningEnabled && learningModule != address(0), "LifestyleAgent: learning not enabled");
        _;
    }
    
    /**
     * @dev Enables learning for this agent
     * @param _learningModule The address of the learning module
     */
    function enableLearning(address _learningModule) external onlyOwner {
        require(_learningModule != address(0), "LifestyleAgent: learning module is zero address");
        require(!learningEnabled, "LifestyleAgent: learning already enabled");
        
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
        try ILearningModule(learningModule).recordInteraction(
            uint256(uint160(address(this))), // Use contract address as token ID
            interactionType,
            success
        ) {
            emit LearningInsightGenerated(interactionType, metadata, block.timestamp);
        } catch {
            // Silently fail to not break agent functionality
        }
    }
    
    /**
     * @dev Updates the user's preferences with learning enhancements
     * @param _travelPreferences The user's travel preferences
     * @param _dietaryRestrictions The user's dietary restrictions
     * @param _workSchedule The user's work schedule
     * @param _leisureActivities The user's leisure activities
     * @param _communicationStyle The user's communication style
     * @param _adaptabilityLevel The adaptability level (0-100)
     * @param _learningObjectives The learning objectives
     * @param _proactivityLevel The proactivity level (0-100)
     * @param _personalizationDepth The personalization depth (0-100)
     */
    function updatePreferences(
        string memory _travelPreferences,
        string memory _dietaryRestrictions,
        string memory _workSchedule,
        string memory _leisureActivities,
        string memory _communicationStyle,
        uint256 _adaptabilityLevel,
        string[] memory _learningObjectives,
        uint256 _proactivityLevel,
        uint256 _personalizationDepth
    ) 
        external 
        onlyOwner 
    {
        require(_adaptabilityLevel <= 100, "LifestyleAgent: adaptability level must be 0-100");
        require(_proactivityLevel <= 100, "LifestyleAgent: proactivity level must be 0-100");
        require(_personalizationDepth <= 100, "LifestyleAgent: personalization depth must be 0-100");
        
        preferences = Preferences({
            travelPreferences: _travelPreferences,
            dietaryRestrictions: _dietaryRestrictions,
            workSchedule: _workSchedule,
            leisureActivities: _leisureActivities,
            communicationStyle: _communicationStyle,
            adaptabilityLevel: _adaptabilityLevel,
            learningObjectives: _learningObjectives,
            proactivityLevel: _proactivityLevel,
            personalizationDepth: _personalizationDepth
        });
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("preferences_update", true, abi.encode(_adaptabilityLevel, _proactivityLevel));
        }
    }
    
    /**
     * @dev Creates a calendar event with learning enhancements
     * @param _title The title of the event
     * @param _description The description of the event
     * @param _startTime The start time of the event
     * @param _endTime The end time of the event
     * @param _location The location of the event
     * @param _isRecurring Whether the event is recurring
     * @param _recurringInterval The recurring interval of the event
     * @param _recurringEndTime The end time of the recurring event
     * @param _isReminder Whether the event is a reminder
     * @param _eventTags Tags for categorization
     * @param _expectedStressLevel Expected stress level (0-100)
     * @return eventId The ID of the new event
     */
    function createCalendarEvent(
        string memory _title,
        string memory _description,
        uint256 _startTime,
        uint256 _endTime,
        string memory _location,
        bool _isRecurring,
        uint256 _recurringInterval,
        uint256 _recurringEndTime,
        bool _isReminder,
        string[] memory _eventTags,
        uint256 _expectedStressLevel
    ) 
        external 
        onlyOwner 
        returns (uint256 eventId) 
    {
        require(_startTime > block.timestamp, "LifestyleAgent: start time must be in the future");
        require(_endTime > _startTime, "LifestyleAgent: end time must be after start time");
        require(_expectedStressLevel <= 100, "LifestyleAgent: stress level must be 0-100");
        
        if (_isRecurring) {
            require(_recurringInterval > 0, "LifestyleAgent: recurring interval must be > 0");
            require(_recurringEndTime > _startTime, "LifestyleAgent: recurring end time must be after start time");
        }
        
        eventCount += 1;
        eventId = eventCount;
        
        calendarEvents[eventId] = CalendarEvent({
            id: eventId,
            title: _title,
            description: _description,
            startTime: _startTime,
            endTime: _endTime,
            location: _location,
            isRecurring: _isRecurring,
            recurringInterval: _recurringInterval,
            recurringEndTime: _recurringEndTime,
            isReminder: _isReminder,
            completed: false,
            userEngagement: 0,
            satisfactionScore: 50, // Default neutral satisfaction
            eventTags: _eventTags,
            stressLevel: _expectedStressLevel
        });
        
        emit CalendarEventCreated(eventId, _title, _startTime);
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("event_creation", true, abi.encode(_eventTags, _expectedStressLevel));
        }
        
        return eventId;
    }
    
    /**
     * @dev Creates a travel plan with learning enhancements
     * @param _destination The destination of the travel plan
     * @param _departureTime The departure time of the travel plan
     * @param _returnTime The return time of the travel plan
     * @param _accommodation The accommodation of the travel plan
     * @param _transportation The transportation of the travel plan
     * @param _activities The activities of the travel plan
     * @return planId The ID of the new travel plan
     */
    function createTravelPlan(
        string memory _destination,
        uint256 _departureTime,
        uint256 _returnTime,
        string memory _accommodation,
        string memory _transportation,
        string[] memory _activities
    ) 
        external 
        onlyOwner 
        returns (uint256 planId) 
    {
        require(_departureTime > block.timestamp, "LifestyleAgent: departure time must be in the future");
        require(_returnTime > _departureTime, "LifestyleAgent: return time must be after departure time");
        
        travelPlanCount += 1;
        planId = travelPlanCount;
        
        travelPlans[planId] = TravelPlan({
            id: planId,
            destination: _destination,
            departureTime: _departureTime,
            returnTime: _returnTime,
            accommodation: _accommodation,
            transportation: _transportation,
            activities: _activities,
            confirmed: false,
            enjoymentRating: 0,
            budgetEfficiency: 50, // Default neutral efficiency
            preferredActivities: new string[](0),
            stressLevel: 30 // Default low stress for travel
        });
        
        emit TravelPlanCreated(planId, _destination, _departureTime);
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("travel_planning", true, abi.encode(_destination, _activities.length));
        }
        
        return planId;
    }
    
    /**
     * @dev Records travel plan feedback for learning
     * @param _planId The ID of the travel plan
     * @param _enjoymentRating User enjoyment rating (0-100)
     * @param _budgetEfficiency Budget efficiency rating (0-100)
     * @param _preferredActivities Activities the user enjoyed most
     * @param _actualStressLevel Actual stress level experienced
     */
    function recordTravelFeedback(
        uint256 _planId,
        uint256 _enjoymentRating,
        uint256 _budgetEfficiency,
        string[] memory _preferredActivities,
        uint256 _actualStressLevel
    ) external onlyOwner {
        require(_planId <= travelPlanCount && _planId > 0, "LifestyleAgent: travel plan does not exist");
        require(_enjoymentRating <= 100, "LifestyleAgent: enjoyment rating must be 0-100");
        require(_budgetEfficiency <= 100, "LifestyleAgent: budget efficiency must be 0-100");
        require(_actualStressLevel <= 100, "LifestyleAgent: stress level must be 0-100");
        
        TravelPlan storage plan = travelPlans[_planId];
        plan.enjoymentRating = _enjoymentRating;
        plan.budgetEfficiency = _budgetEfficiency;
        plan.preferredActivities = _preferredActivities;
        plan.stressLevel = _actualStressLevel;
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("travel_feedback", true, abi.encode(_enjoymentRating, _actualStressLevel));
        }
    }
    
    /**
     * @dev Creates a task with learning enhancements
     * @param _title The title of the task
     * @param _description The description of the task
     * @param _dueDate The due date of the task
     * @param _priority The priority of the task
     * @param _skillsRequired Skills required for this task
     * @return taskId The ID of the new task
     */
    function createTask(
        string memory _title,
        string memory _description,
        uint256 _dueDate,
        uint256 _priority,
        string[] memory _skillsRequired
    ) 
        external 
        onlyOwner 
        returns (uint256 taskId) 
    {
        require(_priority >= 1 && _priority <= 5, "LifestyleAgent: priority must be between 1 and 5");
        
        taskCount += 1;
        taskId = taskCount;
        
        tasks[taskId] = Task({
            id: taskId,
            title: _title,
            description: _description,
            dueDate: _dueDate,
            priority: _priority,
            completed: false,
            completionTime: 0,
            difficultyRating: 0,
            skillsRequired: _skillsRequired,
            procrastinationLevel: 0
        });
        
        emit TaskCreated(taskId, _title, _dueDate);
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("task_creation", true, abi.encode(_priority, _skillsRequired.length));
        }
        
        return taskId;
    }
    
    /**
     * @dev Completes a task with learning analytics
     * @param _taskId The ID of the task
     * @param _difficultyRating User-rated difficulty (0-100)
     * @param _procrastinationLevel How much the user procrastinated (0-100)
     */
    function completeTask(
        uint256 _taskId,
        uint256 _difficultyRating,
        uint256 _procrastinationLevel
    ) 
        external 
        onlyOwner 
    {
        require(_taskId <= taskCount && _taskId > 0, "LifestyleAgent: task does not exist");
        require(!tasks[_taskId].completed, "LifestyleAgent: task already completed");
        require(_difficultyRating <= 100, "LifestyleAgent: difficulty rating must be 0-100");
        require(_procrastinationLevel <= 100, "LifestyleAgent: procrastination level must be 0-100");
        
        Task storage task = tasks[_taskId];
        task.completed = true;
        task.completionTime = block.timestamp;
        task.difficultyRating = _difficultyRating;
        task.procrastinationLevel = _procrastinationLevel;
        
        // Update behavior pattern
        behaviorPattern.averageTaskCompletionTime = (behaviorPattern.averageTaskCompletionTime + 
            (block.timestamp - task.dueDate)) / 2;
        behaviorPattern.procrastinationTendency = (behaviorPattern.procrastinationTendency + 
            _procrastinationLevel) / 2;
        behaviorPattern.lastUpdated = block.timestamp;
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("task_completion", true, abi.encode(_difficultyRating, _procrastinationLevel));
        }
    }
    
    /**
     * @dev Updates behavior pattern based on learning
     * @param _averageTaskCompletionTime Average task completion time
     * @param _preferredWorkingHours Preferred working hours
     * @param _procrastinationTendency Procrastination tendency (0-100)
     * @param _stressThreshold Stress threshold (0-100)
     * @param _productiveEnvironments Productive environments
     */
    function updateBehaviorPattern(
        uint256 _averageTaskCompletionTime,
        uint256 _preferredWorkingHours,
        uint256 _procrastinationTendency,
        uint256 _stressThreshold,
        string[] memory _productiveEnvironments
    ) external onlyOwner {
        require(_preferredWorkingHours <= 23, "LifestyleAgent: working hours must be 0-23");
        require(_procrastinationTendency <= 100, "LifestyleAgent: procrastination tendency must be 0-100");
        require(_stressThreshold <= 100, "LifestyleAgent: stress threshold must be 0-100");
        
        behaviorPattern = UserBehaviorPattern({
            averageTaskCompletionTime: _averageTaskCompletionTime,
            preferredWorkingHours: _preferredWorkingHours,
            procrastinationTendency: _procrastinationTendency,
            stressThreshold: _stressThreshold,
            productiveEnvironments: _productiveEnvironments,
            lastUpdated: block.timestamp
        });
        
        emit BehaviorPatternUpdated(block.timestamp);
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("behavior_update", true, abi.encode(_procrastinationTendency, _stressThreshold));
        }
    }
    
    /**
     * @dev Updates lifestyle insights based on learning
     * @param _optimalSchedulingTimes Optimal scheduling times
     * @param _productivityPeaks Productivity peaks
     * @param _stressReductionActivities Stress reduction activities
     * @param _workLifeBalance Work-life balance score (0-100)
     */
    function updateLifestyleInsights(
        string[] memory _optimalSchedulingTimes,
        uint256[] memory _productivityPeaks,
        string[] memory _stressReductionActivities,
        uint256 _workLifeBalance
    ) external onlyOwner {
        require(_workLifeBalance <= 100, "LifestyleAgent: work-life balance must be 0-100");
        
        lifestyleInsights = LifestyleInsights({
            optimalSchedulingTimes: _optimalSchedulingTimes,
            productivityPeaks: _productivityPeaks,
            stressReductionActivities: _stressReductionActivities,
            workLifeBalance: _workLifeBalance,
            lastUpdated: block.timestamp
        });
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("insights_update", true, abi.encode(_workLifeBalance));
        }
    }
    
    /**
     * @dev Updates wellness metrics
     * @param _averageStressLevel Average stress level (0-100)
     * @param _sleepQuality Sleep quality (0-100)
     * @param _exerciseFrequency Exercise frequency (0-100)
     * @param _socialEngagement Social engagement (0-100)
     */
    function updateWellnessMetrics(
        uint256 _averageStressLevel,
        uint256 _sleepQuality,
        uint256 _exerciseFrequency,
        uint256 _socialEngagement
    ) external onlyOwner {
        require(_averageStressLevel <= 100, "LifestyleAgent: stress level must be 0-100");
        require(_sleepQuality <= 100, "LifestyleAgent: sleep quality must be 0-100");
        require(_exerciseFrequency <= 100, "LifestyleAgent: exercise frequency must be 0-100");
        require(_socialEngagement <= 100, "LifestyleAgent: social engagement must be 0-100");
        
        uint256 overallWellbeing = (_sleepQuality + _exerciseFrequency + _socialEngagement + (100 - _averageStressLevel)) / 4;
        
        wellnessMetrics = WellnessMetrics({
            averageStressLevel: _averageStressLevel,
            sleepQuality: _sleepQuality,
            exerciseFrequency: _exerciseFrequency,
            socialEngagement: _socialEngagement,
            overallWellbeing: overallWellbeing,
            lastUpdated: block.timestamp
        });
        
        emit WellnessMetricsUpdated(overallWellbeing, block.timestamp);
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("wellness_update", true, abi.encode(overallWellbeing));
        }
    }
    
    /**
     * @dev Suggests proactive lifestyle optimization
     * @param _suggestion The optimization suggestion
     */
    function suggestLifestyleOptimization(string memory _suggestion) 
        external 
        onlyAgentToken 
        whenLearningEnabled 
    {
        require(preferences.proactivityLevel >= 50, "LifestyleAgent: insufficient proactivity level");
        
        emit LifestyleOptimizationSuggested(_suggestion, block.timestamp);
        emit ProactiveActionTaken("lifestyle_optimization", abi.encode(_suggestion), block.timestamp);
        
        // Record learning interaction
        this.recordInteraction("proactive_suggestion", true, abi.encode(_suggestion));
    }
    
    /**
     * @dev Gets personalized scheduling recommendations
     * @return recommendations Array of scheduling recommendations
     */
    function getPersonalizedSchedulingRecommendations() 
        external 
        view 
        returns (string[] memory recommendations) 
    {
        // Simple recommendation logic based on behavior patterns and wellness metrics
        string[] memory tempRecommendations = new string[](5);
        uint256 recommendationCount = 0;
        
        // Recommend based on stress levels
        if (wellnessMetrics.averageStressLevel > behaviorPattern.stressThreshold) {
            tempRecommendations[recommendationCount] = "schedule_stress_reduction";
            recommendationCount++;
        }
        
        // Recommend based on productivity peaks
        if (lifestyleInsights.productivityPeaks.length > 0) {
            tempRecommendations[recommendationCount] = "optimize_task_timing";
            recommendationCount++;
        }
        
        // Recommend based on work-life balance
        if (lifestyleInsights.workLifeBalance < 60) {
            tempRecommendations[recommendationCount] = "improve_work_life_balance";
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
     * @dev Gets the user's learning progress
     * @return metrics The learning metrics if available
     */
    function getLearningProgress() external view returns (ILearningModule.LearningMetrics memory metrics) {
        if (learningEnabled && learningModule != address(0)) {
            try ILearningModule(learningModule).getLearningMetrics(
                uint256(uint160(address(this)))
            ) returns (ILearningModule.LearningMetrics memory _metrics) {
                return _metrics;
            } catch {
                // Return empty metrics if call fails
            }
        }
    }
    
    // Include all original functions with learning enhancements...
    
    /**
     * @dev Gets the user's preferences with learning data
     * @return The user's enhanced preferences
     */
    function getPreferences() 
        external 
        view 
        returns (Preferences memory) 
    {
        return preferences;
    }
    
    /**
     * @dev Gets behavior pattern
     * @return The current behavior pattern
     */
    function getBehaviorPattern() 
        external 
        view 
        returns (UserBehaviorPattern memory) 
    {
        return behaviorPattern;
    }
    
    /**
     * @dev Gets lifestyle insights
     * @return The current lifestyle insights
     */
    function getLifestyleInsights() 
        external 
        view 
        returns (LifestyleInsights memory) 
    {
        return lifestyleInsights;
    }
    
    /**
     * @dev Gets wellness metrics
     * @return The current wellness metrics
     */
    function getWellnessMetrics() 
        external 
        view 
        returns (WellnessMetrics memory) 
    {
        return wellnessMetrics;
    }
    
    // Include remaining original functions with appropriate learning enhancements...
    
    /**
     * @dev Confirms a travel plan with learning integration
     * @param _planId The ID of the travel plan
     */
    function confirmTravelPlan(uint256 _planId) 
        external 
        onlyOwner 
    {
        require(_planId <= travelPlanCount && _planId > 0, "LifestyleAgent: travel plan does not exist");
        
        travelPlans[_planId].confirmed = true;
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("travel_confirmation", true, abi.encode(_planId));
        }
    }
    
    /**
     * @dev Completes a calendar event with engagement tracking
     * @param _eventId The ID of the event
     * @param _userEngagement User engagement level (0-100)
     * @param _satisfactionScore User satisfaction score (0-100)
     */
    function completeCalendarEvent(
        uint256 _eventId,
        uint256 _userEngagement,
        uint256 _satisfactionScore
    ) 
        external 
        onlyOwner 
    {
        require(_eventId <= eventCount && _eventId > 0, "LifestyleAgent: event does not exist");
        require(!calendarEvents[_eventId].completed, "LifestyleAgent: event already completed");
        require(_userEngagement <= 100, "LifestyleAgent: engagement must be 0-100");
        require(_satisfactionScore <= 100, "LifestyleAgent: satisfaction must be 0-100");
        
        CalendarEvent storage event_ = calendarEvents[_eventId];
        event_.completed = true;
        event_.userEngagement = _userEngagement;
        event_.satisfactionScore = _satisfactionScore;
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("event_completion", true, abi.encode(_userEngagement, _satisfactionScore));
        }
    }
    
    /**
     * @dev Triggers a reminder with learning analytics
     * @param _eventId The ID of the event
     */
    function triggerReminder(uint256 _eventId) 
        external 
        onlyAgentToken 
    {
        require(_eventId <= eventCount && _eventId > 0, "LifestyleAgent: event does not exist");
        
        CalendarEvent storage event_ = calendarEvents[_eventId];
        require(event_.isReminder, "LifestyleAgent: event is not a reminder");
        require(!event_.completed, "LifestyleAgent: reminder already completed");
        require(block.timestamp >= event_.startTime, "LifestyleAgent: reminder time not reached");
        
        emit ReminderTriggered(_eventId, event_.title);
        
        // Record learning interaction
        if (learningEnabled) {
            this.recordInteraction("reminder_triggered", true, abi.encode(_eventId));
        }
    }
    
    /**
     * @dev Gets the upcoming calendar events with learning optimization
     * @param _count The number of events to return
     * @return An array of upcoming calendar events
     */
    function getUpcomingEvents(uint256 _count) 
        external 
        view 
        returns (CalendarEvent[] memory) 
    {
        // Count upcoming events
        uint256 upcomingCount = 0;
        for (uint256 i = 1; i <= eventCount; i++) {
            if (!calendarEvents[i].completed && calendarEvents[i].startTime > block.timestamp) {
                upcomingCount++;
            }
        }
        
        uint256 resultCount = _count > upcomingCount ? upcomingCount : _count;
        CalendarEvent[] memory upcoming = new CalendarEvent[](resultCount);
        
        // Fill array with upcoming events, sorted by start time
        uint256 index = 0;
        for (uint256 i = 1; i <= eventCount && index < resultCount; i++) {
            if (!calendarEvents[i].completed && calendarEvents[i].startTime > block.timestamp) {
                upcoming[index] = calendarEvents[i];
                index++;
            }
        }
        
        // Simple bubble sort by start time
        for (uint256 i = 0; i < resultCount - 1; i++) {
            for (uint256 j = 0; j < resultCount - i - 1; j++) {
                if (upcoming[j].startTime > upcoming[j + 1].startTime) {
                    CalendarEvent memory temp = upcoming[j];
                    upcoming[j] = upcoming[j + 1];
                    upcoming[j + 1] = temp;
                }
            }
        }
        
        return upcoming;
    }
    
    /**
     * @dev Gets the upcoming travel plans with learning insights
     * @return An array of upcoming travel plans
     */
    function getUpcomingTravelPlans() 
        external 
        view 
        returns (TravelPlan[] memory) 
    {
        // Count upcoming travel plans
        uint256 upcomingCount = 0;
        for (uint256 i = 1; i <= travelPlanCount; i++) {
            if (travelPlans[i].departureTime > block.timestamp) {
                upcomingCount++;
            }
        }
        
        TravelPlan[] memory upcoming = new TravelPlan[](upcomingCount);
        
        // Fill array with upcoming travel plans
        uint256 index = 0;
        for (uint256 i = 1; i <= travelPlanCount; i++) {
            if (travelPlans[i].departureTime > block.timestamp) {
                upcoming[index] = travelPlans[i];
                index++;
            }
        }
        
        return upcoming;
    }
    
    /**
     * @dev Gets the pending tasks with learning prioritization
     * @return An array of pending tasks
     */
    function getPendingTasks() 
        external 
        view 
        returns (Task[] memory) 
    {
        // Count pending tasks
        uint256 pendingCount = 0;
        for (uint256 i = 1; i <= taskCount; i++) {
            if (!tasks[i].completed) {
                pendingCount++;
            }
        }
        
        Task[] memory pending = new Task[](pendingCount);
        
        // Fill array with pending tasks
        uint256 index = 0;
        for (uint256 i = 1; i <= taskCount; i++) {
            if (!tasks[i].completed) {
                pending[index] = tasks[i];
                index++;
            }
        }
        
        return pending;
    }
    
    /**
     * @dev Gets the pending reminders with learning optimization
     * @return An array of pending reminders
     */
    function getPendingReminders() 
        external 
        view 
        returns (CalendarEvent[] memory) 
    {
        // Count pending reminders
        uint256 pendingCount = 0;
        for (uint256 i = 1; i <= eventCount; i++) {
            if (!calendarEvents[i].completed && calendarEvents[i].isReminder) {
                pendingCount++;
            }
        }
        
        CalendarEvent[] memory pending = new CalendarEvent[](pendingCount);
        
        // Fill array with pending reminders
        uint256 index = 0;
        for (uint256 i = 1; i <= eventCount; i++) {
            if (!calendarEvents[i].completed && calendarEvents[i].isReminder) {
                pending[index] = calendarEvents[i];
                index++;
            }
        }
        
        return pending;
    }
}
