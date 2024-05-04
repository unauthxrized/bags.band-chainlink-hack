// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IUserStorage {
    function getBalance(address user) external view returns (uint32);
}