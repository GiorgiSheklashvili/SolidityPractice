// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 900 seconds;
  bool public openForWithdraw = false;
  
  event Stake(address indexed sender, uint256 _stakedAmount);

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable deadlineReached(false) stakeNotCompleted{
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  modifier deadlineReached(bool requireReached){
    uint256 timeRemaining = timeLeft();
    if(requireReached) {
      require(timeRemaining == 0, "Deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Deadline is already reached");
    }
    _;
  }
  
  /**
  * @notice Modifier that require the external contract to not be completed
  */
  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public stakeNotCompleted deadlineReached(false){
    //checking that threshohold is reached
    require(address(this).balance >= threshold, "Threshold not reached");

    //transfer all balance to external contract
     (bool sent,) = address(exampleExternalContract).call{value: address(this).balance}(abi.encodeWithSignature("complete()"));
     require(sent, "exampleExternalContract.complete failed");
    //  exampleExternalContract.complete{value: address(this).balance}()
  }

  
  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw(address payable) public deadlineReached(true) stakeNotCompleted {
    uint256 userBalance = balances[msg.sender];
    require(userBalance > 0, "User doesn't have enough balance");
    balances[msg.sender] = 0;
    (bool sent, ) = msg.sender.call{value: userBalance}("");
    require(sent, "Failed to send user balance back to the user");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256){
    if(block.timestamp >= deadline){
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    this.stake{value:msg.value}();
  }

}
