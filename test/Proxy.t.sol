// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CounterV1.sol";
import '../src/CounterV2.sol';
import "../src/Deployer.sol";
import "../src/IProxy.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";


using { create, appendArg } for bytes;
interface CounterV3 {
  function setValue(uint256) external;
  function getValue() external returns (uint256);
  function getAdmin() external returns (address);
  function custom(uint256,uint256) external returns (address);
}
contract ProxyTest is Test {
    address logic1;
    address logic2;
    address logic3;

    function setUp() public {
        logic1 = address(new CounterV1());
        logic2 = address(new CounterV2());
        logic3 = HuffDeployer.deploy("../huff/CounterV3");
        

    }

    function testProxyBasics() public {
        uint256 gasBefore;
        uint256 johnGasUsed;
        uint256 myGasUsed;
        address proxy = deployProxy(vm, logic1, address(this));
        gasBefore = gasleft();
        CounterV1(proxy).setNumber(1);
        johnGasUsed = gasBefore - gasleft();
        uint256 _before = CounterV1(proxy).number();
        CounterV1(proxy).increment();
        uint256 _after = CounterV1(proxy).number();
        assertGt(_after, _before);
        console.log(CounterV1(proxy).version());
        IProxy(proxy).destroy();        
        proxy = deployProxy(vm, logic3, address(this));
        CounterV3 v3 =  CounterV3(proxy);
        gasBefore = gasleft();
        // v3.setValue(1);
        console.log(v3.custom(125,2),address(this));
        myGasUsed = gasBefore - gasleft();
        
        console.log("CounterV1.increment gasProfiling");
        console.log("==============================");

        console.log("Jtriley's proxy gas used: ");
        console.log(johnGasUsed);
        console.log("====");
        console.log("HP2 proxy gas used: ");
        console.log(myGasUsed);
        // console.log(CounterV3(proxy).getValue());

    }

    function testProxyOwnerDestroy() public {
        address proxy = deployProxy(vm, logic1, logic1);
        uint256 _before = CounterV1(proxy).number();
        CounterV1(proxy).increment();
        uint256 _after = CounterV1(proxy).number();
        assertGt(_after, _before);
        try IProxy(proxy).destroy() {
            // We shouldn't be able to destroy the proxy
            fail();
            
        } catch {}
    }
}
