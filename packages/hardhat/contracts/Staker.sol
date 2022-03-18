// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 0;
  uint256 private deadline = block.timestamp + 30;

  bool private openForWithdraw = false;

  event Stake(address from, uint256 amount);

  ExampleExternalContract public exampleExternalContract;

  modifier deadlineReached( bool requireReached ) {
    uint256 timeRemaining = timeLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Deadline is already reached");
    }
    _;
  }

  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() external payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
    deadline = block.timestamp + 30 seconds;
    openForWithdraw = false;
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() external {
    uint256 time = this.timeLeft();
    
    if (time == 0 && address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = time == 0;
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw(address payable)` function lets users withdraw their balance

  function withdraw(address payable destination) external returns(bool) {
    uint256 userBalance = balances[msg.sender];
    require(userBalance > 0, "You have no funds to withdraw");
    balances[msg.sender] = 0;
    (bool sent, ) = msg.sender.call{value: userBalance}("");
    require(sent, "FAILED TO SEND FUNDS");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256) {
    if(block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()


}
