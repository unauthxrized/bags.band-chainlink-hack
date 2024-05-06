// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IUserStorage } from "./interface/IUserStorage.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract BagsBandPool is Ownable {
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
    
    constructor(address userstorage, address oracle) Ownable(msg.sender) payable {
        STORAGE = IUserStorage(userstorage);
        ORACLE = AggregatorV3Interface(oracle);
    }

    // SETTERS

    function makePosition(bool typeOf, uint128 amount) external returns (UserPosition memory) {
        STORAGE.makePosition(msg.sender, amount);
        UserPosition memory pos;

        pos.position = typeOf;
        pos.amount = amount;
        pos.price = _getPriceConverted();

        position[msg.sender] = pos;
        return pos;
    }

    function closePosition() external returns (bool) {

    }

    // GETTERS

    // PRIVATE

    function _getPriceConverted() private view returns (int120) {
        (, int256 price, , , ) = ORACLE.latestRoundData();
        return SafeCast.toInt120(price);
    }
}
