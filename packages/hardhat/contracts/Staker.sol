// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 1 ether;

  event Stake(address from, uint256 amount);

  uint256 private deadline = block.timestamp;

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() external payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
    deadline = block.timestamp + 30 seconds;
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw(address payable)` function lets users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() external view returns (uint256) {
    if(block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()


}
