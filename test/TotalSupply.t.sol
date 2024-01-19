// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Test } from "../lib/forge-std/src/Test.sol";

import { TotalSupply } from "../src/types/TotalSupply.sol";

contract TotalSupplyTest is Test {
    TotalSupply internal totalSupply;

    function testReadWrite() public {
        assertEq(totalSupply.read(), 0);

        totalSupply.write(1);
        assertEq(totalSupply.read(), 1);

        totalSupply.write(2);
        assertEq(totalSupply.read(), 2);

        totalSupply.write(0);
        assertEq(totalSupply.read(), 0);
    }

    function testFuzzReadWrite(uint256 amount0, uint256 amount1) public {
        assertEq(totalSupply.read(), 0);

        totalSupply.write(amount0);
        assertEq(totalSupply.read(), amount0);

        totalSupply.write(amount1);
        assertEq(totalSupply.read(), amount1);

        totalSupply.write(0);
        assertEq(totalSupply.read(), 0);
    }

    function testIncrease() public {
        assertEq(totalSupply.read(), 0);

        totalSupply.increase(1);
        assertEq(totalSupply.read(), 1);

        totalSupply.increase(2);
        assertEq(totalSupply.read(), 3);
    }

    function testIncraseOverflow() public {
        assertEq(totalSupply.read(), 0);
        totalSupply.write(type(uint256).max);
        assertEq(totalSupply.read(), type(uint256).max);

        vm.expectRevert();
        totalSupply.increase(1);
    }

    function testFuzzIncrease(uint256 amount0, uint256 amount1) public {
        bool overflow = type(uint256).max - amount0 < amount1;
        assertEq(totalSupply.read(), 0);

        totalSupply.increase(amount0);
        assertEq(totalSupply.read(), amount0);

        if (overflow) {
            vm.expectRevert();
        }
        totalSupply.increase(amount1);
        if (!overflow) {
            assertEq(totalSupply.read(), amount0 + amount1);
        }
    }

    function testDecrease() public {
        assertEq(totalSupply.read(), 0);
        totalSupply.write(10);
        assertEq(totalSupply.read(), 10);

        totalSupply.decrease(1);
        assertEq(totalSupply.read(), 9);

        totalSupply.decrease(2);
        assertEq(totalSupply.read(), 7);
    }

    function testDecreaseUnderflow() public {
        assertEq(totalSupply.read(), 0);

        vm.expectRevert();
        totalSupply.decrease(1);
    }

    function testFuzzDecrease(uint256 increaseAmount, uint256 decreaseAmount) public {
        bool underflow = increaseAmount < decreaseAmount;
        assertEq(totalSupply.read(), 0);
        totalSupply.increase(increaseAmount);
        assertEq(totalSupply.read(), increaseAmount);

        if (underflow) {
            vm.expectRevert();
        }

        totalSupply.decrease(decreaseAmount);

        if (!underflow) {
            assertEq(totalSupply.read(), increaseAmount - decreaseAmount);
        }
    }
}
