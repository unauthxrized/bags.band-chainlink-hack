// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract UserStorage {

    mapping (address => uint32) public lp;
    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isProtocol;
    mapping (address => mapping (address => uint)) public userStake;

    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function getBalance(address user) external view returns (uint32) {
        return lp[user];
    }
}