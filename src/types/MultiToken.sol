// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Token } from "./Token.sol";
import { Operators } from "./Operators.sol";

struct MultiToken {
    mapping(uint256 => Token) tokens;
    Operators operators;
}

using {
    balanceOf,
    totalSupply,
    allowance,
    isOperator,
    mint,
    burn,
    transfer,
    transferFrom,
    approve,
    setOperator
} for MultiToken global;

function balanceOf(MultiToken storage self, uint256 id, address account) view returns (uint256) {
    return self.tokens[id].balanceOf(account);
}

function totalSupply(MultiToken storage self, uint256 id) view returns (uint256) {
    return self.tokens[id].totalSupply();
}

function allowance(
    MultiToken storage self,
    uint256 id,
    address owner,
    address spender
) view returns (uint256) {
    return self.tokens[id].allowance(owner, spender);
}

function isOperator(MultiToken storage self, address owner, address operator) view returns (bool) {
    return self.operators.read(owner, operator);
}

function mint(
    MultiToken storage self,
    uint256 id,
    address receiver,
    uint256 amount
) returns (MultiToken storage) {
    self.tokens[id].mint(receiver, amount);
    return self;
}

function burn(
    MultiToken storage self,
    uint256 id,
    address sender,
    uint256 amount
) returns (MultiToken storage) {
    self.tokens[id].burn(sender, amount);
    return self;
}

function transfer(
    MultiToken storage self,
    uint256 id,
    address sender,
    address receiver,
    uint256 amount
) returns (MultiToken storage) {
    self.tokens[id].transfer(sender, receiver, amount);
    return self;
}

function transferFrom(
    MultiToken storage self,
    uint256 id,
    address spender,
    address sender,
    address receiver,
    uint256 amount
) returns (MultiToken storage) {
    if (spender != sender && self.operators.read(sender, spender)) {
        self.tokens[id].allowances.decrease(spender, sender, amount);
    }
    self.tokens[id].balances.decrease(sender, amount);
    self.tokens[id].balances.increase(receiver, amount);
    return self;
}

function approve(
    MultiToken storage self,
    uint256 id,
    address owner,
    address spender,
    uint256 amount
) returns (MultiToken storage) {
    self.tokens[id].approve(owner, spender, amount);
    return self;
}

function setOperator(
    MultiToken storage self,
    address owner,
    address operator,
    bool approved
) returns (MultiToken storage) {
    self.operators.write(owner, operator, approved);
    return self;
}
