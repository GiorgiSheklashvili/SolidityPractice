pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
contract Lottery{
    address payable[] public players;
    
    address public manager;
    
    constructor() {
        manager = msg.sender;
    }
    
    function random() public view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length))); // not perfect random number, miner can exploit this function
    }
    
    fallback() external payable {
        require(msg.value > 0.01 ether);
        players.push(payable(msg.sender));
    }
    
    event Received(address sender, uint value);   // declaring event

    receive() external payable {
        require(msg.value > 0.01 ether);
        players.push(payable(msg.sender));
        emit Received(msg.sender, msg.value);
    }
    
    
    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }
    
    function chooseWinner() public {
        require(msg.sender == manager);
        uint r = random();
        
        address payable winner;
        
        uint index = r % players.length;
        winner = players[index];
        winner.transfer(address(this).balance);
        players = new address payable[](0);
    }
    
}