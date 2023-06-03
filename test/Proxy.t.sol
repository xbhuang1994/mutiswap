// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CounterV1.sol";
import '../src/CounterV2.sol';
import "../src/Deployer.sol";
import "../src/IProxy.sol";

using { create, appendArg } for bytes;

contract ProxyTest is Test {
    address logic1;
    address logic2;

    function setUp() public {
        logic1 = address(new CounterV1());
        logic2 = address(new CounterV2());
    }

    function testProxyBasics() public {
        address proxy = deployProxy(vm, logic1, address(this));
        uint256 _before = CounterV1(proxy).number();
        CounterV1(proxy).increment();
        uint256 _after = CounterV1(proxy).number();
        assertGt(_after, _before);
        console.log(CounterV1(proxy).version());
        IProxy(proxy).destroy();        
        proxy = deployProxy(vm, logic2, address(this));
        console.log(CounterV1(proxy).version());

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
