// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import { IERC826 } from "./IERC826.sol";

/**
 * @dev Outrun's ERC6909 implementation, modified from @solmate implementation
 */
contract SP is IERC826 {
    string public name;

    string public symbol;

    uint8 public immutable decimals;

    mapping(address => mapping(address => bool)) public isOperator;

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(uint256 => uint256)) public lockTime;

    mapping(address => mapping(uint256 => uint256)) public startTime;

    mapping(address => mapping(address => mapping(uint256 => uint256))) public allowance;



    constructor() {
        name = "SP Token";
        symbol = "SP";
        decimals = 18;
    }

    function transfer(
        address receiver,
        uint256 id,
        uint256 amount
    ) external returns (bool) {
        balanceOf[msg.sender][id] -= amount;

        balanceOf[receiver][id] += amount;

        emit Transfer(msg.sender, msg.sender, receiver, id, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address receiver,
        uint256 id,
        uint256 amount
    ) external returns (bool) {
        if (msg.sender != sender && !isOperator[sender][msg.sender]) {
            uint256 allowed = allowance[sender][msg.sender][id];
            if (allowed != type(uint256).max) allowance[sender][msg.sender][id] = allowed - amount;
        }

        balanceOf[sender][id] -= amount;

        balanceOf[receiver][id] += amount;

        emit Transfer(msg.sender, sender, receiver, id, amount);

        return true;
    }

    function approve(
        address spender,
        uint256 id,
        uint256 amount
    ) external returns (bool) {
        allowance[msg.sender][spender][id] = amount;

        emit Approval(msg.sender, spender, id, amount);

        return true;
    }

    function setOperator(address operator, bool approved) external returns (bool) {
        isOperator[msg.sender][operator] = approved;

        emit OperatorSet(msg.sender, operator, approved);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x0f632fb3; // ERC165 Interface ID for ERC6909
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint(
        address receiver,
        uint256 id,
        uint256 amount,
        uint256 _lockTime
    ) external returns (bool) {
        _mint(receiver, id, amount, _lockTime);
        return true;
    }

    function _mint(
        address receiver,
        uint256 id,
        uint256 amount,
        uint256 _lockTime
    ) internal {
        balanceOf[receiver][id] += amount;
        lockTime[receiver][id] = _lockTime;
        startTime[receiver][id] = block.timestamp;

        emit Transfer(msg.sender, address(0), receiver, id, amount);
    }

    function _burn(
        address sender,
        uint256 id,
        uint256 amount
    ) internal {
        balanceOf[sender][id] -= amount;


        emit Transfer(msg.sender, sender, address(0), id, amount);
    }
}