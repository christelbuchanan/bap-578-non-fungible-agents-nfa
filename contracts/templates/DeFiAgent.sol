// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DeFiAgent
 * @dev Template for DeFi agents that can execute trades and manage portfolios
 */
contract DeFiAgent is Ownable {
    // The address of the BEP007 token that owns this logic
    address public agentToken;
    
    // The address of the DEX router
    address public dexRouter;
    
    // The address of the treasury
    address public treasury;
    
    // The trading strategy parameters
    struct TradingStrategy {
        uint256 buyThreshold;  // Price threshold to buy (in basis points below moving average)
        uint256 sellThreshold; // Price threshold to sell (in basis points above moving average)
        uint256 maxSlippage;   // Maximum allowed slippage (in basis points)
        uint256 tradeSize;     // Size of each trade (in percentage of available balance)
        uint256 cooldownPeriod; // Cooldown period between trades (in seconds)
    }
    
    // The trading strategy
    TradingStrategy public strategy;
    
    // The last trade timestamp
    uint256 public lastTradeTimestamp;
    
    // The price oracle
    AggregatorV3Interface public priceOracle;
    
    // The moving average of the price
    uint256 public movingAverage;
    
    // The tokens that the agent can trade
    mapping(address => bool) public allowedTokens;
    
    // Event emitted when a trade is executed
    event TradeExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
    
    // Event emitted when the strategy is updated
    event StrategyUpdated(
        uint256 buyThreshold,
        uint256 sellThreshold,
        uint256 maxSlippage,
        uint256 tradeSize,
        uint256 cooldownPeriod
    );
    
    /**
     * @dev Initializes the contract
     * @param _agentToken The address of the BEP007 token
     * @param _dexRouter The address of the DEX router
     * @param _treasury The address of the treasury
     * @param _priceOracle The address of the price oracle
     */
    constructor(
        address _agentToken,
        address _dexRouter,
        address _treasury,
        address _priceOracle
    ) {
        require(_agentToken != address(0), "DeFiAgent: agent token is zero address");
        require(_dexRouter != address(0), "DeFiAgent: DEX router is zero address");
        require(_treasury != address(0), "DeFiAgent: treasury is zero address");
        require(_priceOracle != address(0), "DeFiAgent: price oracle is zero address");
        
        agentToken = _agentToken;
        dexRouter = _dexRouter;
        treasury = _treasury;
        priceOracle = AggregatorV3Interface(_priceOracle);
        
        // Set default strategy
        strategy = TradingStrategy({
            buyThreshold: 500,    // 5% below moving average
            sellThreshold: 500,   // 5% above moving average
            maxSlippage: 100,     // 1% max slippage
            tradeSize: 2000,      // 20% of available balance
            cooldownPeriod: 3600  // 1 hour cooldown
        });
        
        // Initialize moving average with current price
        (, int256 price, , , ) = priceOracle.latestRoundData();
        movingAverage = uint256(price);
    }
    
    /**
     * @dev Modifier to check if the caller is the agent token
     */
    modifier onlyAgentToken() {
        require(msg.sender == agentToken, "DeFiAgent: caller is not agent token");
        _;
    }
    
    /**
     * @dev Updates the trading strategy
     * @param _buyThreshold The new buy threshold
     * @param _sellThreshold The new sell threshold
     * @param _maxSlippage The new max slippage
     * @param _tradeSize The new trade size
     * @param _cooldownPeriod The new cooldown period
     */
    function updateStrategy(
        uint256 _buyThreshold,
        uint256 _sellThreshold,
        uint256 _maxSlippage,
        uint256 _tradeSize,
        uint256 _cooldownPeriod
    ) 
        external 
        onlyOwner 
    {
        require(_buyThreshold <= 2000, "DeFiAgent: buy threshold too high");
        require(_sellThreshold <= 2000, "DeFiAgent: sell threshold too high");
        require(_maxSlippage <= 500, "DeFiAgent: max slippage too high");
        require(_tradeSize <= 5000, "DeFiAgent: trade size too high");
        
        strategy = TradingStrategy({
            buyThreshold: _buyThreshold,
            sellThreshold: _sellThreshold,
            maxSlippage: _maxSlippage,
            tradeSize: _tradeSize,
            cooldownPeriod: _cooldownPeriod
        });
        
        emit StrategyUpdated(
            _buyThreshold,
            _sellThreshold,
            _maxSlippage,
            _tradeSize,
            _cooldownPeriod
        );
    }
    
    /**
     * @dev Adds a token to the allowed tokens list
     * @param token The address of the token
     */
    function addAllowedToken(address token) 
        external 
        onlyOwner 
    {
        require(token != address(0), "DeFiAgent: token is zero address");
        allowedTokens[token] = true;
    }
    
    /**
     * @dev Removes a token from the allowed tokens list
     * @param token The address of the token
     */
    function removeAllowedToken(address token) 
        external 
        onlyOwner 
    {
        allowedTokens[token] = false;
    }
    
    /**
     * @dev Executes a trade based on the current market conditions
     * @param tokenIn The address of the input token
     * @param tokenOut The address of the output token
     * @param amountIn The amount of input tokens
     * @param minAmountOut The minimum amount of output tokens
     * @param path The path of the trade
     */
    function executeTrade(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path
    ) 
        external 
        onlyAgentToken 
    {
        require(allowedTokens[tokenIn], "DeFiAgent: token in not allowed");
        require(allowedTokens[tokenOut], "DeFiAgent: token out not allowed");
        require(block.timestamp >= lastTradeTimestamp + strategy.cooldownPeriod, "DeFiAgent: cooldown period not elapsed");
        
        // Update the moving average
        updateMovingAverage();
        
        // Check if the trade meets the strategy criteria
        require(validateTrade(tokenIn, tokenOut, amountIn, minAmountOut), "DeFiAgent: trade does not meet strategy criteria");
        
        // Execute the trade
        // Note: In a real implementation, this would call the DEX router
        // For simplicity, we'll just emit an event
        
        // Update the last trade timestamp
        lastTradeTimestamp = block.timestamp;
        
        emit TradeExecuted(tokenIn, tokenOut, amountIn, minAmountOut);
    }
    
    /**
     * @dev Validates a trade against the strategy criteria
     * @param tokenIn The address of the input token
     * @param tokenOut The address of the output token
     * @param amountIn The amount of input tokens
     * @param minAmountOut The minimum amount of output tokens
     * @return Whether the trade is valid
     */
    function validateTrade(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) 
        internal 
        view 
        returns (bool) 
    {
        // Get the current price
        (, int256 price, , , ) = priceOracle.latestRoundData();
        uint256 currentPrice = uint256(price);
        
        // Check if the price meets the buy/sell thresholds
        if (tokenIn == address(0)) {
            // Buying - check if price is below buy threshold
            uint256 buyPrice = movingAverage - ((movingAverage * strategy.buyThreshold) / 10000);
            return currentPrice <= buyPrice;
        } else {
            // Selling - check if price is above sell threshold
            uint256 sellPrice = movingAverage + ((movingAverage * strategy.sellThreshold) / 10000);
            return currentPrice >= sellPrice;
        }
    }
    
    /**
     * @dev Updates the moving average with the current price
     */
    function updateMovingAverage() 
        internal 
    {
        // Get the current price
        (, int256 price, , , ) = priceOracle.latestRoundData();
        uint256 currentPrice = uint256(price);
        
        // Update the moving average (simple EMA with 0.1 weight)
        movingAverage = ((movingAverage * 9) + currentPrice) / 10;
    }
    
    /**
     * @dev Withdraws tokens from the agent
     * @param token The address of the token
     * @param amount The amount of tokens to withdraw
     * @param recipient The address to send the tokens to
     */
    function withdrawTokens(
        address token,
        uint256 amount,
        address recipient
    ) 
        external 
        onlyOwner 
    {
        require(recipient != address(0), "DeFiAgent: recipient is zero address");
        
        if (token == address(0)) {
            // Withdraw BNB
            payable(recipient).transfer(amount);
        } else {
            // Withdraw tokens
            IERC20(token).transfer(recipient, amount);
        }
    }
    
    /**
     * @dev Receive function to accept BNB
     */
    receive() external payable {}
}
