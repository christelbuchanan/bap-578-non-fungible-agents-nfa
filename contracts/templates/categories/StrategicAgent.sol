// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title StrategicAgent
 * @dev Template for strategic agents that monitor trends and detect mentions
 */
contract StrategicAgent is Ownable {
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The address of the data feed
    address public dataFeed;
    
    // The monitoring configuration
    struct MonitoringConfig {
        string[] keywords;
        string[] accounts;
        string[] topics;
        uint256 alertThreshold;
        uint256 scanFrequency;
        bool alertsEnabled;
    }
    
    // The monitoring configuration
    MonitoringConfig public config;
    
    // The alert history
    struct Alert {
        uint256 id;
        string alertType; // "mention", "trend", "sentiment", etc.
        string source;
        string content;
        int256 sentiment;
        uint256 timestamp;
        bool acknowledged;
    }
    
    // The alert history
    mapping(uint256 => Alert) public alertHistory;
    uint256 public alertCount;
    
    // The trend analysis
    struct TrendAnalysis {
        uint256 id;
        string topic;
        int256 sentiment;
        uint256 volume;
        uint256 timestamp;
        string summary;
    }
    
    // The trend analysis history
    mapping(uint256 => TrendAnalysis) public trendAnalysisHistory;
    uint256 public trendAnalysisCount;
    
    // The sentiment analysis
    struct SentimentAnalysis {
        int256 overallSentiment;
        uint256 positiveCount;
        uint256 neutralCount;
        uint256 negativeCount;
        uint256 lastUpdated;
    }
    
    // The sentiment analysis for each keyword
    mapping(string => SentimentAnalysis) public keywordSentiment;
    
    // Event emitted when an alert is triggered
    event AlertTriggered(uint256 indexed alertId, string alertType, string source);
    
    // Event emitted when a trend analysis is completed
    event TrendAnalysisCompleted(uint256 indexed analysisId, string topic, int256 sentiment);
    
    // Event emitted when the monitoring configuration is updated
    event MonitoringConfigUpdated(string[] keywords, string[] accounts, string[] topics);
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _dataFeed The address of the data feed
     * @param _keywords The keywords to monitor
     * @param _accounts The accounts to monitor
     * @param _topics The topics to monitor
     */
    constructor(
        address _agentToken,
        address _dataFeed,
        string[] memory _keywords,
        string[] memory _accounts,
        string[] memory _topics
    ) {
        require(_agentToken != address(0), "StrategicAgent: agent token is zero address");
        
        agentToken = _agentToken;
        dataFeed = _dataFeed;
        
        config = MonitoringConfig({
            keywords: _keywords,
            accounts: _accounts,
            topics: _topics,
            alertThreshold: 70, // Default threshold (70%)
            scanFrequency: 3600, // Default scan frequency (1 hour)
            alertsEnabled: true
        });
    }
    
    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "StrategicAgent: caller is not agent token");
        _;
    }
    
    /**
     * @dev Updates the monitoring configuration
     * @param _keywords The keywords to monitor
     * @param _accounts The accounts to monitor
     * @param _topics The topics to monitor
     * @param _alertThreshold The alert threshold
     * @param _scanFrequency The scan frequency
     * @param _alertsEnabled Whether alerts are enabled
     */
    function updateMonitoringConfig(
        string[] memory _keywords,
        string[] memory _accounts,
        string[] memory _topics,
        uint256 _alertThreshold,
        uint256 _scanFrequency,
        bool _alertsEnabled
    ) 
        external 
        onlyOwner 
    {
        require(_alertThreshold <= 100, "StrategicAgent: threshold must be <= 100");
        
        config = MonitoringConfig({
            keywords: _keywords,
            accounts: _accounts,
            topics: _topics,
            alertThreshold: _alertThreshold,
            scanFrequency: _scanFrequency,
            alertsEnabled: _alertsEnabled
        });
        
        emit MonitoringConfigUpdated(_keywords, _accounts, _topics);
    }
    
    /**
     * @dev Records an alert
     * @param _alertType The type of alert
     * @param _source The source of the alert
     * @param _content The content of the alert
     * @param _sentiment The sentiment of the alert
     */
    function recordAlert(
        string memory _alertType,
        string memory _source,
        string memory _content,
        int256 _sentiment
    ) 
        external 
        onlyAgentToken 
    {
        require(config.alertsEnabled, "StrategicAgent: alerts are disabled");
        
        alertCount += 1;
        
        alertHistory[alertCount] = Alert({
            id: alertCount,
            alertType: _alertType,
            source: _source,
            content: _content,
            sentiment: _sentiment,
            timestamp: block.timestamp,
            acknowledged: false
        });
        
        emit AlertTriggered(alertCount, _alertType, _source);
    }
    
    /**
     * @dev Acknowledges an alert
     * @param _alertId The ID of the alert
     */
    function acknowledgeAlert(uint256 _alertId) 
        external 
        onlyOwner 
    {
        require(_alertId <= alertCount && _alertId > 0, "StrategicAgent: alert does not exist");
        
        alertHistory[_alertId].acknowledged = true;
    }
    
    /**
     * @dev Records a trend analysis
     * @param _topic The topic of the analysis
     * @param _sentiment The sentiment of the analysis
     * @param _volume The volume of the analysis
     * @param _summary The summary of the analysis
     */
    function recordTrendAnalysis(
        string memory _topic,
        int256 _sentiment,
        uint256 _volume,
        string memory _summary
    ) 
        external 
        onlyAgentToken 
    {
        trendAnalysisCount += 1;
        
        trendAnalysisHistory[trendAnalysisCount] = TrendAnalysis({
            id: trendAnalysisCount,
            topic: _topic,
            sentiment: _sentiment,
            volume: _volume,
            timestamp: block.timestamp,
            summary: _summary
        });
        
        emit TrendAnalysisCompleted(trendAnalysisCount, _topic, _sentiment);
    }
    
    /**
     * @dev Updates the sentiment analysis for a keyword
     * @param _keyword The keyword
     * @param _sentiment The sentiment value (-100 to 100)
     * @param _isPositive Whether the sentiment is positive
     * @param _isNeutral Whether the sentiment is neutral
     * @param _isNegative Whether the sentiment is negative
     */
    function updateSentiment(
        string memory _keyword,
        int256 _sentiment,
        bool _isPositive,
        bool _isNeutral,
        bool _isNegative
    ) 
        external 
        onlyAgentToken 
    {
        require(_sentiment >= -100 && _sentiment <= 100, "StrategicAgent: sentiment must be between -100 and 100");
        
        SentimentAnalysis storage analysis = keywordSentiment[_keyword];
        
        // Update counts
        if (_isPositive) {
            analysis.positiveCount += 1;
        } else if (_isNeutral) {
            analysis.neutralCount += 1;
        } else if (_isNegative) {
            analysis.negativeCount += 1;
        }
        
        // Update overall sentiment (weighted average)
        uint256 totalCount = analysis.positiveCount + analysis.neutralCount + analysis.negativeCount;
        
        if (totalCount == 1) {
            // First entry
            analysis.overallSentiment = _sentiment;
        } else {
            // Weighted average
            analysis.overallSentiment = (analysis.overallSentiment * int256(totalCount - 1) + _sentiment) / int256(totalCount);
        }
        
        analysis.lastUpdated = block.timestamp;
    }
    
    /**
     * @dev Gets the monitoring configuration
     * @return The monitoring configuration
     */
    function getMonitoringConfig() 
        external 
        view 
        returns (MonitoringConfig memory) 
    {
        return config;
    }
    
    /**
     * @dev Gets the recent alerts
     * @param _count The number of alerts to return
     * @return An array of recent alerts
     */
    function getRecentAlerts(uint256 _count) 
        external 
        view 
        returns (Alert[] memory) 
    {
        uint256 resultCount = _count > alertCount ? alertCount : _count;
        Alert[] memory alerts = new Alert[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            alerts[i] = alertHistory[alertCount - i];
        }
        
        return alerts;
    }
    
    /**
     * @dev Gets the recent trend analyses
     * @param _count The number of analyses to return
     * @return An array of recent trend analyses
     */
    function getRecentTrendAnalyses(uint256 _count) 
        external 
        view 
        returns (TrendAnalysis[] memory) 
    {
        uint256 resultCount = _count > trendAnalysisCount ? trendAnalysisCount : _count;
        TrendAnalysis[] memory analyses = new TrendAnalysis[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            analyses[i] = trendAnalysisHistory[trendAnalysisCount - i];
        }
        
        return analyses;
    }
    
    /**
     * @dev Gets the sentiment analysis for a keyword
     * @param _keyword The keyword
     * @return The sentiment analysis
     */
    function getKeywordSentiment(string memory _keyword) 
        external 
        view 
        returns (SentimentAnalysis memory) 
    {
        return keywordSentiment[_keyword];
    }
    
    /**
     * @dev Gets the overall sentiment across all keywords
     * @return The overall sentiment
     */
    function getOverallSentiment() 
        external 
        view 
        returns (int256) 
    {
        int256 totalSentiment = 0;
        uint256 keywordCount = 0;
        
        for (uint256 i = 0; i < config.keywords.length; i++) {
            SentimentAnalysis storage analysis = keywordSentiment[config.keywords[i]];
            
            if (analysis.lastUpdated > 0) {
                totalSentiment += analysis.overallSentiment;
                keywordCount++;
            }
        }
        
        if (keywordCount == 0) {
            return 0;
        }
        
        return totalSentiment / int256(keywordCount);
    }
    
    /**
     * @dev Checks if an alert should be triggered based on sentiment
     * @param _sentiment The sentiment value
     * @return Whether an alert should be triggered
     */
    function shouldTriggerAlert(int256 _sentiment) 
        external 
        view 
        returns (bool) 
    {
        if (!config.alertsEnabled) {
            return false;
        }
        
        // Convert sentiment to absolute value for threshold comparison
        uint256 sentimentAbs = _sentiment < 0 ? uint256(-_sentiment) : uint256(_sentiment);
        
        return sentimentAbs >= config.alertThreshold;
    }
}
