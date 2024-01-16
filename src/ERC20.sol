// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Allowances } from "./types/Allowances.sol";
import { Balances } from "./types/Balances.sol";
import { TotalSupply } from "./types/TotalSupply.sol";

struct ERC20Store {
    TotalSupply totalSupply;
    Balances balances;
    Allowances allowances;
}

contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    ERC20Store internal self;

    function totalSupply() public view returns (uint256) {
        return self.totalSupply.read();
    }

    function balanceOf(address account) public view returns (uint256) {
        return self.balances.read(account);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return self.allowances.read(owner, spender);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        self.balances.decrease(msg.sender, amount).increase(recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        if (msg.sender != sender) self.allowances.decrease(sender, msg.sender, amount);
        self.balances.decrease(sender, amount).increase(recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        self.allowances.write(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}
