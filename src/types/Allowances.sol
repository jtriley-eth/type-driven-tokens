// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

struct Allowances {
    mapping(address => mapping(address => uint256)) _inner;
}

using { read, write, increase, decrease } for Allowances global;

function read(Allowances storage self, address owner, address spender) view returns (uint256) {
    return self._inner[owner][spender];
}

function write(
    Allowances storage self,
    address owner,
    address spender,
    uint256 amount
) returns (Allowances storage) {
    self._inner[owner][spender] = amount;
    return self;
}

function increase(
    Allowances storage self,
    address owner,
    address spender,
    uint256 amount
) returns (Allowances storage) {
    self._inner[owner][spender] += amount;
    return self;
}

function decrease(
    Allowances storage self,
    address owner,
    address spender,
    uint256 amount
) returns (Allowances storage) {
    self._inner[owner][spender] -= amount;
    return self;
}
