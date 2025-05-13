// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title LifestyleAgent
 * @dev Template for lifestyle agents that handle travel, scheduling, and reminders
 */
contract LifestyleAgent is Ownable {
    using Strings for uint256;
    
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The user's preferences
    struct Preferences {
        string travelPreferences;
        string dietaryRestrictions;
        string workSchedule;
        string leisureActivities;
        string communicationStyle;
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
    }
    
    // The task list
    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;
    
    // Event emitted when a calendar event is created
    event CalendarEventCreated(uint256 indexed eventId, string title, uint256 startTime);
    
    // Event emitted when a travel plan is created
    event TravelPlanCreated(uint256 indexed planId, string destination, uint256 departureTime);
    
    // Event emitted when a task is created
    event TaskCreated(uint256 indexed taskId, string title, uint256 dueDate);
    
    // Event emitted when a reminder is triggered
    event ReminderTriggered(uint256 indexed eventId, string title);
    
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
            leisureActivities:<pivotalAction type="file" filePath="/home/project/contracts/templates/categories/LifestyleAgent.sol">// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title LifestyleAgent
 * @dev Template for lifestyle agents that handle travel, scheduling, and reminders
 */
contract LifestyleAgent is Ownable {
    using Strings for uint256;
    
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The user's preferences
    struct Preferences {
        string travelPreferences;
        string dietaryRestrictions;
        string workSchedule;
        string leisureActivities;
        string communicationStyle;
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
    }
    
    // The task list
    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;
    
    // Event emitted when a calendar event is created
    event CalendarEventCreated(uint256 indexed eventId, string title, uint256 startTime);
    
    // Event emitted when a travel plan is created
    event TravelPlanCreated(uint256 indexed planId, string destination, uint256 departureTime);
    
    // Event emitted when a task is created
    event TaskCreated(uint256 indexed taskId, string title, uint256 dueDate);
    
    // Event emitted when a reminder is triggered
    event ReminderTriggered(uint256 indexed eventId, string title);
    
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
            communicationStyle: _communicationStyle
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
     * @dev Updates the user's preferences
     * @param _travelPreferences The user's travel preferences
     * @param _dietaryRestrictions The user's dietary restrictions
     * @param _workSchedule The user's work schedule
     * @param _leisureActivities The user's leisure activities
     * @param _communicationStyle The user's communication style
     */
    function updatePreferences(
        string memory _travelPreferences,
        string memory _dietaryRestrictions,
        string memory _workSchedule,
        string memory _leisureActivities,
        string memory _communicationStyle
    ) 
        external 
        onlyOwner 
    {
        preferences = Preferences({
            travelPreferences: _travelPreferences,
            dietaryRestrictions: _dietaryRestrictions,
            workSchedule: _workSchedule,
            leisureActivities: _leisureActivities,
            communicationStyle: _communicationStyle
        });
    }
    
    /**
     * @dev Creates a calendar event
     * @param _title The title of the event
     * @param _description The description of the event
     * @param _startTime The start time of the event
     * @param _endTime The end time of the event
     * @param _location The location of the event
     * @param _isRecurring Whether the event is recurring
     * @param _recurringInterval The recurring interval of the event
     * @param _recurringEndTime The end time of the recurring event
     * @param _isReminder Whether the event is a reminder
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
        bool _isReminder
    ) 
        external 
        onlyOwner 
        returns (uint256 eventId) 
    {
        require(_startTime > block.timestamp, "LifestyleAgent: start time must be in the future");
        require(_endTime > _startTime, "LifestyleAgent: end time must be after start time");
        
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
            completed: false
        });
        
        emit CalendarEventCreated(eventId, _title, _startTime);
        
        return eventId;
    }
    
    /**
     * @dev Creates a travel plan
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
            confirmed: false
        });
        
        emit TravelPlanCreated(planId, _destination, _departureTime);
        
        return planId;
    }
    
    /**
     * @dev Confirms a travel plan
     * @param _planId The ID of the travel plan
     */
    function confirmTravelPlan(uint256 _planId) 
        external 
        onlyOwner 
    {
        require(_planId <= travelPlanCount && _planId > 0, "LifestyleAgent: travel plan does not exist");
        
        travelPlans[_planId].confirmed = true;
    }
    
    /**
     * @dev Creates a task
     * @param _title The title of the task
     * @param _description The description of the task
     * @param _dueDate The due date of the task
     * @param _priority The priority of the task
     * @return taskId The ID of the new task
     */
    function createTask(
        string memory _title,
        string memory _description,
        uint256 _dueDate,
        uint256 _priority
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
            completed: false
        });
        
        emit TaskCreated(taskId, _title, _dueDate);
        
        return taskId;
    }
    
    /**
     * @dev Completes a task
     * @param _taskId The ID of the task
     */
    function completeTask(uint256 _taskId) 
        external 
        onlyOwner 
    {
        require(_taskId <= taskCount && _taskId > 0, "LifestyleAgent: task does not exist");
        require(!tasks[_taskId].completed, "LifestyleAgent: task already completed");
        
        tasks[_taskId].completed = true;
    }
    
    /**
     * @dev Completes a calendar event
     * @param _eventId The ID of the event
     */
    function completeCalendarEvent(uint256 _eventId) 
        external 
        onlyOwner 
    {
        require(_eventId <= eventCount && _eventId > 0, "LifestyleAgent: event does not exist");
        require(!calendarEvents[_eventId].completed, "LifestyleAgent: event already completed");
        
        calendarEvents[_eventId].completed = true;
    }
    
    /**
     * @dev Triggers a reminder
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
    }
    
    /**
     * @dev Gets the user's preferences
     * @return The user's preferences
     */
    function getPreferences() 
        external 
        view 
        returns (Preferences memory) 
    {
        return preferences;
    }
    
    /**
     * @dev Gets the upcoming calendar events
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
     * @dev Gets the upcoming travel plans
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
     * @dev Gets the pending tasks
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
     * @dev Gets the pending reminders
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
