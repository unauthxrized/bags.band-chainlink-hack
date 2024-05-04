// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract UserStorage is Ownable {
    uint32 pools;

    mapping (address => uint32) public avbllp;
    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isProtocol;
    mapping (address => mapping (address => bool)) public userPosition;
    mapping (uint32 => address) public pool;

    error NotProtocol(address sender);
    error NotExpectedAmount(address sender, uint32 lp);
    error BadRequest(address sender, address user);
    error BalanceError(address sender, address user, uint32 requestlp, uint32 balancelp);

    modifier onlyProtocol {
        if(!isProtocol[msg.sender]) { revert NotProtocol(msg.sender); }
        _;
    }

    constructor() Ownable(msg.sender) payable {}

    // SETTERS

    function requestLp(address user, uint32 requestedLp) external onlyProtocol {
        _checkUserRegistration(user);
    }

    function closeUserPosition(address user, uint32 reward) external onlyProtocol {

    }

    // GETTERS

    function getBalance(address user) external view returns (uint32) {
        return avbllp[user];
    }

    // PRIVATE

    function _checkUserRegistration(address user) private {
        if (!isRegistered[user]) {
            isRegistered[user] = true;
            avbllp[user] = 10000;
        }
    }
}