// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { TotalSupply } from "./TotalSupply.sol";

struct MultiTotalSupply {
    mapping(uint256 => TotalSupply) _inner;
}

using { read, write, increase, decrease } for MultiTotalSupply global;

function read(MultiTotalSupply storage self, uint256 id) view returns (uint256) {
    return self._inner[id].read();
}

function write(MultiTotalSupply storage self, uint256 id, uint256 amount) returns (MultiTotalSupply storage) {
    self._inner[id].write(amount);
    return self;
}

function increase(MultiTotalSupply storage self, uint256 id, uint256 amount) returns (MultiTotalSupply storage) {
    self._inner[id].increase(amount);
    return self;
}

function decrease(MultiTotalSupply storage self, uint256 id, uint256 amount) returns (MultiTotalSupply storage) {
    self._inner[id].decrease(amount);
    return self;
}
