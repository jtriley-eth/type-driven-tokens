// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Balances } from "./Balances.sol";

struct MultiBalances {
    mapping(uint256 => Balances) _inner;
}

using { read, increase, decrease } for MultiBalances global;

function read(MultiBalances storage self, uint256 id, address account) view returns (uint256) {
    return self._inner[id].read(account);
}

function increase(
    MultiBalances storage self,
    uint256 id,
    address account,
    uint256 amount
) returns (MultiBalances storage) {
    self._inner[id].increase(account, amount);
    return self;
}

function decrease(
    MultiBalances storage self,
    uint256 id,
    address account,
    uint256 amount
) returns (MultiBalances storage) {
    self._inner[id].decrease(account, amount);
    return self;
}
