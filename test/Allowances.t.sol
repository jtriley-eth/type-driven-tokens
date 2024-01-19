// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Test } from "../lib/forge-std/src/Test.sol";

import { Allowances } from "../src/types/Allowances.sol";

contract AllowancesTest is Test {
    Allowances internal allowances;
    address internal alice = vm.addr(1);
    address internal bob = vm.addr(2);

    function testReadWrite() public {
        assertEq(allowances.read(alice, bob), 0);

        allowances.write(alice, bob, 1);
        assertEq(allowances.read(alice, bob), 1);

        allowances.write(alice, bob, 2);
        assertEq(allowances.read(alice, bob), 2);

        allowances.write(alice, bob, 0);
        assertEq(allowances.read(alice, bob), 0);
    }

    function testFuzzReadWrite(
        address owner,
        address spender,
        uint256 amount0,
        uint256 amount1
    ) public {
        assertEq(allowances.read(owner, spender), 0);

        allowances.write(owner, spender, amount0);
        assertEq(allowances.read(owner, spender), amount0);

        allowances.write(owner, spender, amount1);
        assertEq(allowances.read(owner, spender), amount1);

        allowances.write(owner, spender, 0);
        assertEq(allowances.read(owner, spender), 0);
    }

    function testIncrease() public {
        assertEq(allowances.read(alice, bob), 0);

        allowances.increase(alice, bob, 1);
        assertEq(allowances.read(alice, bob), 1);

        allowances.increase(alice, bob, 2);
        assertEq(allowances.read(alice, bob), 3);
    }

    function testIncraseOverflow() public {
        assertEq(allowances.read(alice, bob), 0);
        allowances.write(alice, bob, type(uint256).max);
        assertEq(allowances.read(alice, bob), type(uint256).max);

        vm.expectRevert();
        allowances.increase(alice, bob, 1);
    }

    function testFuzzIncrease(
        address owner,
        address spender,
        uint256 amount0,
        uint256 amount1
    ) public {
        bool overflow = type(uint256).max - amount0 < amount1;
        assertEq(allowances.read(owner, spender), 0);

        allowances.increase(owner, spender, amount0);
        assertEq(allowances.read(owner, spender), amount0);

        if (overflow) vm.expectRevert();

        allowances.increase(owner, spender, amount1);

        if (!overflow) assertEq(allowances.read(owner, spender), amount0 + amount1);
    }

    function testDecrease() public {
        assertEq(allowances.read(alice, bob), 0);
        allowances.write(alice, bob, 3);
        assertEq(allowances.read(alice, bob), 3);

        allowances.decrease(alice, bob, 1);
        assertEq(allowances.read(alice, bob), 2);

        allowances.decrease(alice, bob, 2);
        assertEq(allowances.read(alice, bob), 0);
    }

    function testDecreaseUnderflow() public {
        assertEq(allowances.read(alice, bob), 0);

        vm.expectRevert();
        allowances.decrease(alice, bob, 1);
    }

    function testFuzzDecrease(
        address owner,
        address spender,
        uint256 amount0,
        uint256 amount1
    ) public {
        bool underflow = amount0 < amount1;
        assertEq(allowances.read(owner, spender), 0);
        allowances.write(owner, spender, amount0);
        assertEq(allowances.read(owner, spender), amount0);

        if (underflow) vm.expectRevert();

        allowances.decrease(owner, spender, amount1);

        if (!underflow) assertEq(allowances.read(owner, spender), amount0 - amount1);
    }
}
