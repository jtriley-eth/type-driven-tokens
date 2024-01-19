// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Test } from "../lib/forge-std/src/Test.sol";

import { Balances } from "../src/types/Balances.sol";

contract BalancesTest is Test {
    Balances internal balances;
    address internal alice = vm.addr(1);

    function testReadWrite() public {
        assertEq(balances.read(alice), 0);

        balances.write(alice, 1);
        assertEq(balances.read(alice), 1);

        balances.write(alice, 2);
        assertEq(balances.read(alice), 2);

        balances.write(alice, 0);
        assertEq(balances.read(alice), 0);
    }

    function testFuzzReadWrite(address account, uint256 amount0, uint256 amount1) public {
        assertEq(balances.read(account), 0);

        balances.write(account, amount0);
        assertEq(balances.read(account), amount0);

        balances.write(account, amount1);
        assertEq(balances.read(account), amount1);

        balances.write(account, 0);
        assertEq(balances.read(account), 0);
    }

    function testIncrease() public {
        assertEq(balances.read(alice), 0);

        balances.increase(alice, 1);
        assertEq(balances.read(alice), 1);

        balances.increase(alice, 2);
        assertEq(balances.read(alice), 3);
    }

    function testIncraseOverflow() public {
        assertEq(balances.read(alice), 0);
        balances.write(alice, type(uint256).max);
        assertEq(balances.read(alice), type(uint256).max);

        vm.expectRevert();
        balances.increase(alice, 1);
    }

    function testFuzzIncrease(address account, uint256 amount0, uint256 amount1) public {
        bool overflow = type(uint256).max - amount0 < amount1;
        assertEq(balances.read(account), 0);

        balances.increase(account, amount0);
        assertEq(balances.read(account), amount0);

        if (overflow) vm.expectRevert();

        balances.increase(account, amount1);

        if (!overflow) assertEq(balances.read(account), amount0 + amount1);
    }

    function testDecrease() public {
        assertEq(balances.read(alice), 0);
        balances.write(alice, 3);
        assertEq(balances.read(alice), 3);

        balances.decrease(alice, 1);
        assertEq(balances.read(alice), 2);

        balances.decrease(alice, 2);
        assertEq(balances.read(alice), 0);
    }

    function testDecreaseUnderflow() public {
        assertEq(balances.read(alice), 0);

        vm.expectRevert();
        balances.decrease(alice, 1);
    }

    function testFuzzDecrease(address account, uint256 amount0, uint256 amount1) public {
        bool underflow = amount0 < amount1;
        assertEq(balances.read(account), 0);
        balances.write(account, amount0);
        assertEq(balances.read(account), amount0);

        if (underflow) vm.expectRevert();

        balances.decrease(account, amount1);

        if (!underflow) assertEq(balances.read(account), amount0 - amount1);
    }
}
