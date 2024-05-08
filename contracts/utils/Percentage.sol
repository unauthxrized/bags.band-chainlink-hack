// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Percentage {

    function _ofIncrease(uint128 initialPrice, uint128 price) internal pure returns (uint128, uint128) {
        uint128 increase = price - initialPrice;
        uint128 percentage = (increase * 10000) / price;
        return (increase, percentage);
    }

    function _ofDecrease(uint128 initialPrice, uint128 price) internal pure returns (uint128, uint128) {
        uint128 decrease = initialPrice - price;
        uint128 percentage = (decrease * 10000) / initialPrice;
        return (decrease, percentage);
    }

    function _ofPercent(uint128 percentage, uint128 amount) internal pure returns (uint128) {
        return (amount * percentage) / 10000;
    }

}
