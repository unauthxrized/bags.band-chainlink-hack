// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IBagsBandProtocol } from "./interface/IBagsBandProtocol.sol";

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

    function makePositionFrom(address user, uint128 requestedLp) external onlyProtocol {
        _checkUserRegistration(user);
        if (avbllp[user] < requestedLp) { revert NotExpectedAmount(user, requestedLp); }
        avbllp[user] -= requestedLp;
        userPosition[user][msg.sender] = true;
    }

    function closeUserPosition(address user, uint128 reward) external onlyProtocol returns (bool) {
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

    function calculateUserProfit(address user) public view returns (int128, int128) {
        int128 gained;
        int128 totalpercentage;

        for (uint32 i = 0; i < pools; i++) {
            address _pool = pool[i];
            if (!userPosition[user][_pool]) continue;
            (, uint128 percentage,uint128 lpgained,,bool isWin) = IBagsBandProtocol(_pool).calculateReward(user);
            if (isWin) {
                totalpercentage += int128(percentage);
                gained += int128(lpgained);
            } else {
                totalpercentage -= int128(percentage);
                gained -= int128(lpgained);
            }
        }
        return (gained, totalpercentage);
    }

    function getTotalUsersResults(uint32 from, uint32 until) external view returns (address[] memory, int128[] memory) {
        unchecked {
            address[] memory usersnow = new address[](until - from);
            int128[] memory lps = new int128[](until - from);
            uint32 counter;
            for (uint32 i = from; i < until; i++) {
                address user = usermap[i];
                usersnow[counter] = user;
                int128 balance = int128(avbllp[user]);
                (int128 gained,) = calculateUserProfit(user);
                int128 _lps = balance += gained;
                lps[counter] = _lps;
                counter++;
            }
            return (usersnow, lps);
        }
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