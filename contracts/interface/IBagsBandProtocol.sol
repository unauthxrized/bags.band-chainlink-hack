// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBagsBandProtocol {
    function calculateReward(address user) external view returns (uint128, uint128, uint128, bool, bool);
}