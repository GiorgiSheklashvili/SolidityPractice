pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
contract AuctionCreator{
    address[] public auctions;
    
    function createAuction() public {
        address newAuction = address(new Auction(msg.sender));
        auctions.push(newAuction);
    }
}

contract Auction{
    address public owner;
    address payable public highestBidder;
    uint public highestBid;
    uint public startblock;
    uint public endblock;
    
    enum State {Running, Ended, Canceled}
    State public auctionState;
    mapping(address => uint) public bids;
    
    uint bidIncrement;
    
    constructor(address creator){
        owner = creator;
        auctionState = State.Running;
        startblock = block.number;
        endblock = startblock + 5;   // for testing purposes
        bidIncrement = 1000000000000000000; // 1 eth
    }
    
    function min(uint a, uint b) pure internal returns(uint){
        if(a<b)
            return a;
        else
            return b;
    }
    
    function bid() public payable notOwner afterStart beforeEnd returns(bool) {
        require(auctionState == State.Running);
        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBid);
        bids[msg.sender] = currentBid;
        if(currentBid <= bids[highestBidder]){
            highestBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
        return true;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    
    modifier beforeEnd(){
        require(block.number < endblock);
        _;
    }
    
    modifier afterStart(){
        require(block.number > startblock);
        _;
    }
    
    function finalizeAuction() public {
        require(auctionState == State.Canceled || block.number > endblock);
        
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        address payable recipient;
        uint value;
        
        if(auctionState == State.Canceled){
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            if(msg.sender == owner){
                recipient = payable(owner);
                value = highestBid;
            } else {
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBid; // ?
                } else {
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        recipient.transfer(value);
    }
    
    function cancelAuction() public onlyOwner {
        auctionState = State.Canceled;
    } 
    
}