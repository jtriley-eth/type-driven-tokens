// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Test } from "../lib/forge-std/src/Test.sol";

import { Token } from "../src/types/Token.sol";

contract TokenTest is Test {
    Token internal token;
    address internal alice = vm.addr(1);
    address internal bob = vm.addr(2);

    function testBalanceOf() public {
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        token.balances.write(alice, 1);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);
    }

    function testFuzzBalanceOf(address account, address control, uint256 amount) public {
        vm.assume(account != control);
        assertEq(token.balanceOf(account), 0);
        assertEq(token.balanceOf(control), 0);

        token.balances.write(account, amount);
        assertEq(token.balanceOf(account), amount);
        assertEq(token.balanceOf(control), 0);
    }

    function testTotalSupply() public {
        assertEq(token.totalSupply(), 0);

        token.supply.write(1);
        assertEq(token.totalSupply(), 1);
    }

    function testFuzzTotalSupply(uint256 amount0) public {
        assertEq(token.totalSupply(), 0);

        token.supply.write(amount0);
        assertEq(token.totalSupply(), amount0);
    }

    function testAllowance() public {
        assertEq(token.allowance(alice, bob), 0);

        token.allowances.write(alice, bob, 1);
        assertEq(token.allowance(alice, bob), 1);
    }

    function testFuzzAllowance(address owner, address spender, uint256 amount) public {
        assertEq(token.allowance(owner, spender), 0);

        token.allowances.write(owner, spender, amount);
        assertEq(token.allowance(owner, spender), amount);
    }

    function testMint() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        token.mint(alice, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);
    }

    function testMintOverflow() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        token.mint(alice, type(uint256).max);
        assertEq(token.totalSupply(), type(uint256).max);
        assertEq(token.balanceOf(alice), type(uint256).max);
        assertEq(token.balanceOf(bob), 0);

        vm.expectRevert();
        token.mint(alice, 1);
    }

    function testFuzzMint(address receiver, address control, uint256 mintAmount0, uint256 mintAmount1) public {
        bool overflow = type(uint256).max - mintAmount0 < mintAmount1;
        vm.assume(receiver != control);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(receiver), 0);
        assertEq(token.balanceOf(control), 0);

        token.mint(receiver, mintAmount0);
        assertEq(token.totalSupply(), mintAmount0);
        assertEq(token.balanceOf(receiver), mintAmount0);
        assertEq(token.balanceOf(control), 0);

        if (overflow) {
            vm.expectRevert();
        }

        token.mint(receiver, mintAmount1);
        
        if (!overflow) {
            assertEq(token.totalSupply(), mintAmount0 + mintAmount1);
            assertEq(token.balanceOf(receiver), mintAmount0 + mintAmount1);
            assertEq(token.balanceOf(control), 0);
        }
    }

    function testBurn() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        token.mint(alice, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);

        token.burn(alice, 1);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);
    }

    function testBurnUnderflow() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        vm.expectRevert();
        token.burn(alice, 1);
    }

    function testFuzzBurn(address sender, address control, uint256 mintAmount, uint256 burnAmount) public {
        bool underflow = mintAmount < burnAmount;
        vm.assume(sender != control);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(sender), 0);
        assertEq(token.balanceOf(control), 0);

        token.mint(sender, mintAmount);
        assertEq(token.totalSupply(), mintAmount);
        assertEq(token.balanceOf(sender), mintAmount);
        assertEq(token.balanceOf(control), 0);

        if (underflow) {
            vm.expectRevert();
        }

        token.burn(sender, burnAmount);

        if (!underflow) {
            assertEq(token.totalSupply(), mintAmount - burnAmount);
            assertEq(token.balanceOf(sender), mintAmount - burnAmount);
            assertEq(token.balanceOf(control), 0);
        }
    }

    function testTransfer() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        token.mint(alice, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);

        token.transfer(alice, bob, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 1);
    }

    function testTransferUnderflow() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);

        vm.expectRevert();
        token.transfer(alice, bob, 1);
    }

    function testFuzzTransfer(address sender, address receiver, uint256 mintAmount, uint256 transferAmount) public {
        bool underflow = mintAmount < transferAmount;
        vm.assume(sender != receiver);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(sender), 0);
        assertEq(token.balanceOf(receiver), 0);

        token.mint(sender, mintAmount);
        assertEq(token.totalSupply(), mintAmount);
        assertEq(token.balanceOf(sender), mintAmount);
        assertEq(token.balanceOf(receiver), 0);

        if (underflow) {
            vm.expectRevert();
        }

        token.transfer(sender, receiver, transferAmount);

        if (!underflow) {
            assertEq(token.totalSupply(), mintAmount);
            assertEq(token.balanceOf(sender), mintAmount - transferAmount);
            assertEq(token.balanceOf(receiver), transferAmount);
        }
    }

    function testTransferFrom() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);
        assertEq(token.allowance(alice, bob), 0);

        token.mint(alice, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);
        assertEq(token.allowance(alice, bob), 0);

        token.approve(alice, bob, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);
        assertEq(token.allowance(alice, bob), 1);

        token.transferFrom(bob, alice, bob, 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 1);
        assertEq(token.allowance(alice, bob), 0);
    }

    function testTransferFromBalanceUnderflow() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);
        assertEq(token.allowance(alice, bob), 0);

        token.approve(alice, bob, 1);

        vm.expectRevert();
        token.transferFrom(alice, bob, alice, 1);
    }

    function testTransferFromAllowanceUnderflow() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);
        assertEq(token.allowance(alice, bob), 0);

        token.mint(alice, 1);

        vm.expectRevert();
        token.transferFrom(alice, bob, alice, 1);
    }

    function testFuzzTransferFrom(
        address spender,
        address sender,
        address receiver,
        uint256 mintAmount,
        uint256 approvalAmount,
        uint256 transferAmount
    ) public {
        vm.assume(spender != sender && sender != receiver && spender != receiver);
        bool balanceUnderflow = mintAmount < transferAmount;
        bool allowanceUnderflow = approvalAmount < transferAmount;
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(sender), 0);
        assertEq(token.balanceOf(receiver), 0);
        assertEq(token.allowance(sender, spender), 0);

        token.mint(sender, mintAmount);
        assertEq(token.totalSupply(), mintAmount);
        assertEq(token.balanceOf(sender), mintAmount);
        assertEq(token.balanceOf(receiver), 0);
        assertEq(token.allowance(sender, spender), 0);

        token.approve(sender, spender, approvalAmount);
        assertEq(token.totalSupply(), mintAmount);
        assertEq(token.balanceOf(sender), mintAmount);
        assertEq(token.balanceOf(receiver), 0);
        assertEq(token.allowance(sender, spender), approvalAmount);

        if (balanceUnderflow || allowanceUnderflow) {
            vm.expectRevert();
        }

        token.transferFrom(spender, sender, receiver, transferAmount);

        if (!balanceUnderflow && !allowanceUnderflow) {
            assertEq(token.totalSupply(), mintAmount);
            assertEq(token.balanceOf(sender), mintAmount - transferAmount);
            assertEq(token.balanceOf(receiver), transferAmount);
            assertEq(token.allowance(sender, spender), approvalAmount - transferAmount);
        }
    }

    function testApprove() public {
        assertEq(token.allowance(alice, bob), 0);

        token.approve(alice, bob, 1);
        assertEq(token.allowance(alice, bob), 1);
    }

    function testFuzzApprove(address owner, address spender, uint256 amount) public {
        assertEq(token.allowance(owner, spender), 0);

        token.approve(owner, spender, amount);
        assertEq(token.allowance(owner, spender), amount);
    }
}
