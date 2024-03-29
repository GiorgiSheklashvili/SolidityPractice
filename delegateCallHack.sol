// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
//Delegate-call hack
//Parity wallet hacl https://blog.openzeppelin.com/on-the-parity-wallet-multisig-hack-405a8c12e8f7
contract Delegate {

  address public owner;

  constructor(address _owner) public {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}