// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IUserStorage } from "./interface/IUserStorage.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { Percentage } from "./utils/Percentage.sol";

contract BagsBandPool is Ownable, Percentage {
    AggregatorV3Interface public immutable ORACLE;
    IUserStorage public immutable STORAGE;

    uint64 public totalTransactions;
    uint64 public positionsNow;

    struct UserPosition {
        uint128 amount;
        int120 price;
        bool position;
    }

    mapping (address => UserPosition) public position;

    error NotAcceptedAmount(uint128 amount, address user);
    error BalanceIsZero(address user);
    
    constructor(address userstorage, address oracle) Ownable(msg.sender) payable {
        STORAGE = IUserStorage(userstorage);
        ORACLE = AggregatorV3Interface(oracle);
    }

    // SETTERS

    function makePosition(bool typeOf, uint128 amount) external returns (UserPosition memory) {
        if (amount == 0) { revert NotAcceptedAmount(amount, msg.sender); }

        STORAGE.makePositionFrom(msg.sender, amount);
        positionsNow++;
        totalTransactions++;

        UserPosition memory pos;
        pos.position = typeOf;
        pos.amount = amount;
        pos.price = _getPriceConverted();

        position[msg.sender] = pos;
        return pos;
    }

    function closePosition() external returns (bool) {
        UserPosition memory pos = position[msg.sender];
        if (pos.amount == 0) { revert BalanceIsZero(msg.sender); }

        uint128 currentPrice = _getCurrentPriceToReward();
        uint128 initialPrice = _getUserPrice(pos.price);
        uint128 toStorage;

        if (currentPrice > initialPrice) {
            (, uint128 percentage) = _ofIncrease(initialPrice, currentPrice);
            uint128 lp = _ofPercent(percentage, pos.amount);
            if (pos.position) {
                toStorage = pos.amount + lp;
            } else {
                toStorage = pos.amount - lp;
            }
        }
        if (currentPrice <= initialPrice) {
            (, uint128 percentage) = _ofDecrease(initialPrice, currentPrice);
            uint128 lp = _ofPercent(percentage, pos.amount);
            if (pos.position) {
                toStorage = pos.amount - lp;
            } else {
                toStorage = pos.amount + lp;
            }
        }
        STORAGE.closeUserPosition(msg.sender, toStorage);

        pos.amount = 0;
        pos.price = 0;
        pos.position = false;
        position[msg.sender] = pos;

        positionsNow--;

        return true;
    }

    // GETTERS

    function calculateReward(address user) external view returns (uint128 amount, uint128 percentaged, uint128 ulpgained, bool upos, bool isWin) {
        UserPosition memory pos = position[user];
        uint128 currentPrice = _getCurrentPriceToReward();
        uint128 initialPrice = _getUserPrice(pos.price);
        bool isw;

        if (currentPrice > initialPrice) {
            (uint128 increase, uint128 percentage) = _ofIncrease(initialPrice, currentPrice);
            uint128 lpGained = _ofPercent(percentage, pos.amount);
            if (pos.position) {
                isw = true;
            } else {
                isw = false;
            }
            return (increase, percentage, lpGained, pos.position, isw);
        }
        if (currentPrice <= initialPrice) {
            (uint128 increase, uint128 percentage) = _ofDecrease(initialPrice, currentPrice);
            uint128 lpGained = _ofPercent(percentage, pos.amount);
            if (pos.position) {
                isw = false;
            } else {
                isw = true;
            }
            return (increase, percentage, lpGained, pos.position, isw);
        }
    }

    // PRIVATE

    function _getPriceConverted() private view returns (int120) {
        (, int256 price, , , ) = ORACLE.latestRoundData();
        return SafeCast.toInt120(price);
    }

    function _getCurrentPriceToReward() private view returns (uint128) {
        (, int256 price, , , ) = ORACLE.latestRoundData();
        return SafeCast.toUint128(SafeCast.toUint256(price));
    }

    function _getUserPrice(int120 price) private pure returns (uint128) {
        return SafeCast.toUint128(uint256(int256(price)));
    }

}
