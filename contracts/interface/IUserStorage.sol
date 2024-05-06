// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IUserStorage {
    function getBalance(address user) external view returns (uint128);
    function makePosition(address user, uint128 requestedLp) external;
    function closeUserPosition(address user, uint32 reward) external returns (bool);
}