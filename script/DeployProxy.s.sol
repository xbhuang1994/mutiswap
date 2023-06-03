// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/CounterV1.sol";
import "../src/Deployer.sol";

using { compile } for Vm;
using { create, appendArg } for bytes;

contract GasProfiler is Script {
    address mySuperiorProxy;

    address impl;
    uint256 deployerPrivateKey;

    function setUp() public {
    
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress('WALLET_ADDRESS');
        console.log(address(this));
        console.log(admin);
        vm.startBroadcast(deployerPrivateKey);
        impl = address(new CounterV1());
        mySuperiorProxy = deployProxy(vm, impl, admin);
        vm.stopBroadcast();
    }

    function run() public {
        uint256 gasBefore;
        uint256 myGasUsed;

        gasBefore = gasleft();
        CounterV1(mySuperiorProxy).increment();
        myGasUsed = gasBefore - gasleft();

        console.log("CounterV1.increment gasProfiling");
        console.log("==============================");
        console.log("HP2 proxy gas used: ");
        console.log(myGasUsed);
    }
}
