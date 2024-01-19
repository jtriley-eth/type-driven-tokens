// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Test } from "../lib/forge-std/src/Test.sol";

import { Operators } from "../src/types/Operators.sol";

contract OperatorsTest is Test {
    Operators internal operators;
    address internal alice = vm.addr(1);
    address internal bob = vm.addr(2);

    function testReadWrite() public {
        assertEq(operators.read(alice, bob), false);

        operators.write(alice, bob, true);
        assertEq(operators.read(alice, bob), true);

        operators.write(alice, bob, false);
        assertEq(operators.read(alice, bob), false);
    }

    function testFuzzReadWrite(
        address owner,
        address operator,
        bool approved0,
        bool approved1
    ) public {
        assertEq(operators.read(owner, operator), false);

        operators.write(owner, operator, approved0);
        assertEq(operators.read(owner, operator), approved0);

        operators.write(owner, operator, approved1);
        assertEq(operators.read(owner, operator), approved1);

        operators.write(owner, operator, false);
        assertEq(operators.read(owner, operator), false);
    }
}
