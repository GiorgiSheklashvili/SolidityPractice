// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "hardhat/console.sol";

contract DepositFunds {
    mapping(address => uint) public balances;
    bool internal locked;

    modifier noReentrancy(){ // another way to avoid reentrancy
        require(!locked, "no re-entrancy allowed");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        balances[msg.sender] = 0; // set balance before sending money to avoid reentrancy
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        
    }

}