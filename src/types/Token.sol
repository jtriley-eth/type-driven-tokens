// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Allowances } from "./Allowances.sol";
import { Balances } from "./Balances.sol";
import { TotalSupply } from "./TotalSupply.sol";

struct Token {
    Allowances allowances;
    Balances balances;
    TotalSupply supply;
}

using {
    balanceOf,
    totalSupply,
    allowance,
    mint,
    burn,
    transfer,
    transferFrom,
    approve
} for Token global;

function balanceOf(Token storage self, address account) view returns (uint256) {
    return self.balances.read(account);
}

function totalSupply(Token storage self) view returns (uint256) {
    return self.supply.read();
}

function allowance(Token storage self, address owner, address spender) view returns (uint256) {
    return self.allowances.read(owner, spender);
}

function mint(Token storage self, address receiver, uint256 amount) returns (Token storage) {
    self.balances.increase(receiver, amount);
    self.supply.increase(amount);
    return self;
}

function burn(Token storage self, address sender, uint256 amount) returns (Token storage) {
    self.balances.decrease(sender, amount);
    self.supply.decrease(amount);
    return self;
}

function transfer(
    Token storage self,
    address sender,
    address receiver,
    uint256 amount
) returns (Token storage) {
    self.balances.decrease(sender, amount);
    self.balances.increase(receiver, amount);
    return self;
}

function transferFrom(
    Token storage self,
    address spender,
    address sender,
    address receiver,
    uint256 amount
) returns (Token storage) {
    if (spender != sender) self.allowances.decrease(sender, spender, amount);
    self.balances.decrease(sender, amount);
    self.balances.increase(receiver, amount);
    return self;
}

function approve(
    Token storage self,
    address owner,
    address spender,
    uint256 amount
) returns (Token storage) {
    self.allowances.increase(owner, spender, amount);
    return self;
}
