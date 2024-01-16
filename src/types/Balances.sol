// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

struct Balances {
    mapping(address => uint256) _inner;
}

using { read, increase, decrease } for Balances global;

function read(Balances storage self, address account) view returns (uint256) {
    return self._inner[account];
}

function increase(
    Balances storage self,
    address account,
    uint256 amount
) returns (Balances storage) {
    self._inner[account] += amount;
    return self;
}

function decrease(
    Balances storage self,
    address account,
    uint256 amount
) returns (Balances storage) {
    self._inner[account] -= amount;
    return self;
}
