// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CounterV1 {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
    function version() public pure returns (string memory) {
        return "v1";
    }
}
