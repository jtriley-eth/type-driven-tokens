// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Token } from "./types/Token.sol";

contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    Token internal self;

    function totalSupply() public view returns (uint256) {
        return self.totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {
        return self.balances.read(account);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return self.allowances.read(owner, spender);
    }

    function transfer(address receiver, uint256 amount) public returns (bool) {
        self.transfer(msg.sender, receiver, amount);
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) public returns (bool) {
        self.transferFrom(msg.sender, sender, receiver, amount);
        emit Transfer(sender, receiver, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        self.approve(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}
