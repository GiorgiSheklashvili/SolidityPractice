pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
contract Lottery{
    address payable[] public players;
    
    address public manager;
    
    constructor() {
        manager = msg.sender;
    }
    
    function random() internal pure{
        
    }
    
    receive() payable external {
        require(msg.value > 0.01 ether);
        players.push(payable(msg.sender));
    }
    
    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    
}