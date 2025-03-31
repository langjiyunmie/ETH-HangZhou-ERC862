// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {USTT} from "./USTT.sol";
import {SP} from "./SP.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CON {
    USTT public ustt;
    address public owner;

    uint8 public constant DAILY_DISCOUNT_RATE = 1;

    event RedeemDetails(uint256 id, uint256 amount, uint256 unlockTime, uint256 expectedRedeem, address spAddress);

    event Swap(uint256 id, uint256 amount, address spAddress);

    struct RedeemDetail {
        uint256 id;
        uint256 amount;
        uint256 unlockTime;
        uint256 expectedRedeem;
    }

    event Transfer(address indexed sender, address indexed receiver, uint256 id, uint256 amount);

    mapping(address => mapping(uint256 => RedeemDetail)) public redeemDetail;

    constructor() {}

    function previewExistOut(uint256 id, uint256 outputAmount, address spAddress) public view returns (uint256) {
        require(outputAmount <= redeemDetail[spAddress][id].amount, "out of balance");
        uint256 _rate = outputAmount / redeemDetail[spAddress][id].expectedRedeem;
        uint256 inputAmount = redeemDetail[spAddress][id].amount * _rate;
        return inputAmount;
    }

    function existOutSwap(uint256 _id, address spAddress, uint256 _outputAmount, address tokenAddress) external {
        uint256 inputAmount = previewExistOut(_id, _outputAmount, spAddress);

        IERC20(tokenAddress).transferFrom(address(this), msg.sender, inputAmount);
        SP(spAddress).transfer(msg.sender, _id, _outputAmount);

        emit Swap(_id, inputAmount, spAddress);
    }

    function uploadSP(uint256 id, uint256 input, address spAddress, uint256 output) external {
        SP(spAddress).transferFrom(msg.sender, address(this), id, input);
        redeemDetail[spAddress][id].amount = redeemDetail[spAddress][id].amount + input;
        redeemDetail[spAddress][id].expectedRedeem = output;
        emit RedeemDetails(id, input, redeemDetail[spAddress][id].unlockTime, output, spAddress);
    }
}
