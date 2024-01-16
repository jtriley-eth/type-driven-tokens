// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

struct TotalSupply {
    uint256 _inner;
}

using { read, write, increase, decrease } for TotalSupply global;

function read(TotalSupply storage self) view returns (uint256) {
    return self._inner;
}

function write(TotalSupply storage self, uint256 amount) returns (TotalSupply storage) {
    self._inner = amount;
    return self;
}

function increase(TotalSupply storage self, uint256 amount) returns (TotalSupply storage) {
    self._inner += amount;
    return self;
}

function decrease(TotalSupply storage self, uint256 amount) returns (TotalSupply storage) {
    self._inner -= amount;
    return self;
}
