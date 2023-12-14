// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibDiamond} from "./LibDiamond.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibMeta} from "./LibMeta.sol";

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

struct AppStorage {
    mapping(string => address) contracts;
}

/**
@dev global modifier
 */
contract Modifiers {
    AppStorage internal s;

    modifier onlyDev() {
        LibDiamond.enforceIsContractOwner();
        _;
    }
    // modifier onlyOwner() {
    //     require(LibMeta.msgSender() == s.diamondStorage().contractOwner, "LibAppStorage: must be owner");
    //     _;
    // }
}
