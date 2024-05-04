// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract BagsBandPool is Ownable {
    AggregatorV3Interface public immutable ORACLE;

    struct UserPosition {
        int248 position;
        bool isLong;
    }
    
    constructor(address userstorage) Ownable(msg.sender) payable {}
}
