// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
contract Orderbook is ReentrancyGuard{
    using SafeMath for uint256;
    uint256 public orderId;
    struct Order{
        address maker;
        address makeAsset;
        uint256 makeAmount;
        address taker;
        address takeAsset;
        uint256 takeAmount;
        uint256 salt;
        uint256 startBlock;
        uint256 endBlock;
    }
    mapping(uint256 => Order) public orders; 

    event MakeEvent(uint256 indexed orderId, 
                uint256 makeAmount,
                uint256 takeAmount,
                uint256 timestamp,
                address indexed maker,                
                address makeAsset,                
                address takeAsset                
                );
    event TakeEvent(uint256 indexed orderId, 
                uint256 quantity,
                uint256 fulfilledQuantity,
                uint256 timestamp,
                address indexed maker,  
                address indexed taker,              
                address makeAsset,                
                address takeAsset                
                );

    //can not cancel once there is a taker, so no need
    //for a taker
    event cancelEvent(uint256 indexed orderId, 
                uint256 makeAmount,                
                uint256 takeAmount,
                uint256 timestamp,
                address indexed maker,                
                address makeAsset,                
                address takeAsset );


    function getOrder(uint256 id) public view returns(Order memory order){
        order = orders[id];        
    }
    function getMaker(uint256 id) public view returns (address maker){
        maker =  orders[id].maker;
    }
    function getTaker(uint256 id) public view returns (address taker){
        taker = orders[id].taker;
        require(taker != address(0),"No taker yet");
        
    }
    function openOrder(
            uint256 makeAmount,
            uint256 takeAmount,                
            address makeAsset,  
            address takeAsset) external nonReentrant returns (uint256 id){                        

        require(makeAmount > 0, "Make amount value is low");
        require(takeAmount > 0, "Take amount value is low");
        require(makeAsset != takeAsset, "Make and Take assets are the same");
        require(makeAsset != address(0), "Make Asset address is invalid");
        require(takeAsset != address(0), "Take Asset address is invalid");
        
        Order memory order;
        
        orderId++;  //order id starts from 1
        order.maker = msg.sender;                    
        order.makeAmount = makeAmount;
        order.takeAmount = takeAmount;
        order.makeAsset = makeAsset;
        order.takeAsset = takeAsset;
        order.startBlock = block.timestamp;
        order.endBlock = order.startBlock + 1 days; //order expires after 1 day, if order is not fulfilled                
        orders[orderId] = order;    

        // Note: the makeAsset is an ERC20 asset, the msg.sender needs to have ERC20 to place order
        // Note: Orderbook should have sufficient allowance approved by trader of ERC20 asset
        //todo: create the erc20 asset
        //todo: Add asset to the trader
        //todo: Authorize and set allowance for this orderbook contract and traders
        bool success = ERC20(makeAsset).transferFrom(msg.sender, address(this), makeAmount); //check this         
        require(success, "Failed to place order");
        emit MakeEvent(orderId, makeAmount,takeAmount, block.timestamp, msg.sender ,makeAsset, takeAsset );        
        id = orderId; //return the newly created order id
    }   
    function cancelOrder(uint256 id) external nonReentrant returns(bool success){
        //only maker can cancel live orders       
        
        Order memory order = orders[id];
        require (order.maker == msg.sender, "Invalid Trader" );
        require(order.startBlock > 0, "Invalid Order");
        require (order.endBlock > block.timestamp, "Order has expired");
        require(order.makeAmount > 0,"Order has completed");
        delete orders[id]; //directly delete storage
        //give previously staked maker's amount back to the order maker    
        bool result = ERC20(order.makeAsset).transfer(order.maker, order.makeAmount);
        require(result, "Cancellation Failed");       
        emit cancelEvent(id, order.makeAmount, order.takeAmount, block.timestamp, order.maker, order.makeAsset, order.takeAsset);                
        success = true;
        
    }
    function buyAsset(uint256 id, uint256 quantity) external nonReentrant returns (bool success) {
        
        Order storage order = orders[id];        
        require(order.makeAmount > order.salt, "Order is completed"); //check this
        require(order.startBlock > 0, "Invalid Order");
        require (order.endBlock > block.timestamp, "Order has expired");        
        require(quantity > 0, "Insufficient quantity");
        //taker's quantity 
        uint256 fulfilledQuantity = (quantity.mul(order.makeAmount)).div(order.takeAmount);

        // require(quantity > order.makeAmount && 
        //fulfilledQuantity > order.takeAmount,"Quantity too low");

        order.makeAmount = order.makeAmount.sub(quantity);
        order.takeAmount = order.takeAmount.sub(fulfilledQuantity);    
        order.taker = msg.sender; //is this required?
        //todo: Create and mint takeAsset
        //create users with takeAsset 
        //Authorize Orderbook contract to make trade on behalf of the taker
        bool result = ERC20(order.takeAsset).transferFrom(order.taker, order.maker, fulfilledQuantity);
        require(result, "Taker deposit failed");
        //pay the make amount to taker for having given take asset
        result = ERC20(order.makeAsset).transfer(order.taker, quantity);
        require(result, "Maker withdraw failed");            
        emit TakeEvent(id, quantity, fulfilledQuantity, block.timestamp, order.maker, order.taker, order.makeAsset, order.takeAsset);
        success = true;
    }

}