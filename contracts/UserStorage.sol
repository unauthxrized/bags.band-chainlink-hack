// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract UserStorage is Ownable {
    uint32 public pools;
    uint32 public users;

    mapping (address => uint128) public avbllp;
    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isProtocol;
    mapping (address => mapping (address => bool)) public userPosition;
    mapping (uint32 => address) public pool;
    mapping (uint32 => address) public usermap;

    error NotProtocol(address sender);
    error NotExpectedAmount(address sender, uint128 lp);
    error BadRequest(address sender, address user);
    error BalanceError(address sender, address user, uint32 requestlp, uint32 balancelp);

    modifier onlyProtocol {
        if(!isProtocol[msg.sender]) { revert NotProtocol(msg.sender); }
        _;
    }

    constructor() Ownable(msg.sender) payable {}

    // SETTERS

    function makePosition(address user, uint128 requestedLp) external onlyProtocol {
        _checkUserRegistration(user);
        if (avbllp[user] < requestedLp) { revert NotExpectedAmount(user, requestedLp); }
        avbllp[user] -= requestedLp;
        userPosition[user][msg.sender] = true;
    }

    function closeUserPosition(address user, uint32 reward) external onlyProtocol returns (bool) {
        avbllp[user] += reward;
        userPosition[user][msg.sender] = false;
        return true;
    }

    function addProtocol(address protocol) external onlyOwner {
        if (isProtocol[protocol]) revert();
        isProtocol[protocol] = true;
        pools++;
        pool[pools] = protocol;
    }

    // GETTERS

    function getBalance(address user) external view returns (uint128) {
        return avbllp[user];
    }

    function getAllPools() external view returns(address[] memory) {
        address[] memory localpools = new address[](pools);
        for (uint32 i = 0; i < pools; i++) {
            localpools[i] = pool[i];
        }
        return localpools;
    }

    function calculateUserProfit(address user) external view returns (uint128) {
        //...
    }

    // PRIVATE

    function _checkUserRegistration(address user) private {
        if (!isRegistered[user]) {
            isRegistered[user] = true;
            avbllp[user] = 10000;
            users++;
            usermap[users] = user;
        }
    }
}