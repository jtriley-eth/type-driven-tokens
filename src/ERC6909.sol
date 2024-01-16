// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { MultiAllowances } from "./types/MultiAllowances.sol";
import { MultiBalances } from "./types/MultiBalances.sol";
import { Operators } from "./types/Operators.sol";
import { MultiTotalSupply } from "./types/MultiTotalSupply.sol";

struct ERC6909Store {
    MultiTotalSupply totalSupply;
    MultiBalances balances;
    MultiAllowances allowances;
    Operators operators;
}

contract ERC6909 {
    event Transfer(
        address caller, address indexed from, address indexed to, uint256 indexed id, uint256 value
    );
    event Approval(
        address indexed owner, address indexed spender, uint256 indexed id, bool approved
    );
    event OperatorSet(address indexed owner, address indexed operator, bool approved);

    ERC6909Store internal self;

    function totalSupply(uint256 id) public view returns (uint256) {
        return self.totalSupply.read(id);
    }

    function balanceOf(address owner, uint256 id) public view returns (uint256) {
        return self.balances.read(id, owner);
    }

    function allowance(address owner, address spender, uint256 id) public view returns (uint256) {
        return self.allowances.read(id, owner, spender);
    }

    function isOperator(address owner, address operator) public view returns (bool) {
        return self.operators.read(owner, operator);
    }

    function transfer(address to, uint256 id, uint256 amount) public returns (bool) {
        self.balances.decrease(id, msg.sender, amount).increase(id, to, amount);
        emit Transfer(msg.sender, msg.sender, to, id, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public returns (bool) {
        if (msg.sender != from) self.allowances.decrease(id, from, msg.sender, amount);
        self.balances.decrease(id, from, amount).increase(id, to, amount);
        emit Transfer(msg.sender, from, to, id, amount);
        return true;
    }

    function approve(address spender, uint256 id, uint256 amount) public returns (bool) {
        self.allowances.write(id, msg.sender, spender, amount);
        emit Approval(msg.sender, spender, id, true);
        return true;
    }

    function setOperator(address operator, bool approved) public returns (bool) {
        self.operators.write(msg.sender, operator, approved);
        emit OperatorSet(msg.sender, operator, approved);
        return true;
    }
}
