// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AggregatorV3Mock {
    int256 public cost;

    constructor(int256 _cost) payable {
        cost = _cost;
    }

    function setCost(int _cost) external {
        cost = _cost;
    }
    function decimals() external pure returns (uint8) {
        return 8;
    }

    function description() external pure returns (string memory) {
        return "Hello World!))))";
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (5, cost, 1, 1, 1);
    }
}