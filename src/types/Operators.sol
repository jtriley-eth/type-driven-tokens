// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

struct Operators {
    mapping(address => mapping(address => bool)) _inner;
}

using { read, write } for Operators global;

function read(Operators storage self, address owner, address operator) view returns (bool) {
    return self._inner[owner][operator];
}

function write(
    Operators storage self,
    address owner,
    address operator,
    bool approved
) returns (Operators storage) {
    self._inner[owner][operator] = approved;
    return self;
}
