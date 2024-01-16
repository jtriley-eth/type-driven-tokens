// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Allowances } from "./Allowances.sol";

struct MultiAllowances {
    mapping(uint256 => Allowances) _inner;
}

using { read, write, increase, decrease } for MultiAllowances global;

function read(
    MultiAllowances storage self,
    uint256 id,
    address owner,
    address spender
) view returns (uint256) {
    return self._inner[id].read(owner, spender);
}

function write(
    MultiAllowances storage self,
    uint256 id,
    address owner,
    address spender,
    uint256 amount
) returns (MultiAllowances storage) {
    self._inner[id].write(owner, spender, amount);
    return self;
}

function increase(
    MultiAllowances storage self,
    uint256 id,
    address owner,
    address spender,
    uint256 amount
) returns (MultiAllowances storage) {
    self._inner[id].increase(owner, spender, amount);
    return self;
}

function decrease(
    MultiAllowances storage self,
    uint256 id,
    address owner,
    address spender,
    uint256 amount
) returns (MultiAllowances storage) {
    self._inner[id].decrease(owner, spender, amount);
    return self;
}
