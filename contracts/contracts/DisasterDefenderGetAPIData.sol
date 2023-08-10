//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract DisasterDefenderGetAPIData is KeeperCompatibleInterface, ChainlinkClient {
    
    using Chainlink for Chainlink.Request;
    address owner;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public ethPrice;  // Store Ethereum's price in USD
    bool public fetchDataFlag = false;  // Manual trigger flag
    uint256 public lastFetchTime = 0;   // Store the timestamp of the last fetch
    uint public upKeepcounter;

    struct DisasterInfo {
        string name;
        string typeOfDisaster;
        string severity;
        string location;
        uint256 timestamp;  // Unix timestamp
    }

    DisasterInfo[] public disasters;

    constructor() {
        owner = msg.sender; 
        setPublicChainlinkToken();
        
        // Using Goerli Testnet Oracle for this PoC
        oracle = 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7;
        jobId = "ca98366cc7314957b8c012c72f05aeeb";  // Assuming GET>uint256 job
        fee = 0.1 * 10 ** 18; 
    }
    
    function checkUpkeep(bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {
        bool timeCondition = (block.timestamp - lastFetchTime) > 1 days;
        upkeepNeeded = fetchDataFlag || timeCondition;
        performData = checkData;        
    }

    function performUpkeep(bytes calldata) external override {
        requestData();
        upKeepcounter++;
        lastFetchTime = block.timestamp;
        fetchDataFlag = false;  // Reset the flag after fetching the data
    } 

    function requestData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Using CoinGecko API to get Ethereum's current price in USD
        request.add("get", "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd");
        request.add("path", "ethereum.usd");

        return sendChainlinkRequestTo(oracle, request, fee);                      
    }
    
    function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) {
        ethPrice = _price;
        
        // Adding mock disaster data that matches the UI's dummy data
        disasters.push(DisasterInfo({
            name: "Hurricane Zeta",
            typeOfDisaster: "Hurricane",
            severity: "High",
            location: "East Coast",
            timestamp: block.timestamp
        }));
    }

    // Manually trigger the data fetch
    function manualTrigger() external {
        require(msg.sender == owner, "Only the owner can manually trigger data fetch.");
        fetchDataFlag = true;
    }

    // Manually stop trigger
    function manualTriggerStop() external {
        require(msg.sender == owner, "Only the owner can manually trigger data fetch.");
        fetchDataFlag = false;
    }

    // Get the latest disaster
    function getLatestDisaster() public view returns (DisasterInfo memory) {
        require(disasters.length > 0, "No disasters recorded yet.");
        return disasters[disasters.length - 1];
    }
}
