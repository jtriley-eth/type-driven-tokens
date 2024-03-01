// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { MultiToken } from "./types/MultiToken.sol";

contract ERC6909 {
    event Transfer(
        address caller, address indexed from, address indexed to, uint256 indexed id, uint256 value
    );
    event Approval(
        address indexed owner, address indexed spender, uint256 indexed id, bool approved
    );
    event OperatorSet(address indexed owner, address indexed operator, bool approved);

    // bytes32 public constant STORAGE_SLOT = bytes32(uint256(keccak256('type-driven-tokens.storage.ERC6909)) - 1);
    bytes32 public constant STORAGE_SLOT = 0x894b575d503a5e7d146da3671583044031de353234c66e814bda6299a55ad8e6;
    function self() private pure returns (MultiToken storage $) {
        assembly {
            $.slot := STORAGE_SLOT
        }
    }

    function totalSupply(uint256 id) external view returns (uint256) {
        return self().totalSupply(id);
    }

    function balanceOf(address owner, uint256 id) external view returns (uint256) {
        return self().balanceOf(id, owner);
    }

    function allowance(address owner, address spender, uint256 id) external view returns (uint256) {
        return self().allowance(id, owner, spender);
    }

    function isOperator(address owner, address operator) external view returns (bool) {
        return self().isOperator(owner, operator);
    }

    function transfer(address to, uint256 id, uint256 amount) external returns (bool) {
        self().transfer(id, msg.sender, to, amount);
        emit Transfer(msg.sender, msg.sender, to, id, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external returns (bool) {
        self().transferFrom(id, msg.sender, from, to, amount);
        emit Transfer(msg.sender, from, to, id, amount);
        return true;
    }

    function approve(address spender, uint256 id, uint256 amount) external returns (bool) {
        self().approve(id, msg.sender, spender, amount);
        emit Approval(msg.sender, spender, id, true);
        return true;
    }

    function setOperator(address operator, bool approved) external returns (bool) {
        self().setOperator(msg.sender, operator, approved);
        emit OperatorSet(msg.sender, operator, approved);
        return true;
    }
}
