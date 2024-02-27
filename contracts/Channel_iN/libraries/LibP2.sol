// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IDB} from "../interfaces/IDB.sol";
// libs
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LibP2 {
    using EnumerableSet for EnumerableSet.UintSet;

    function P2_getAienLevel(uint _aienId) internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["db"]).aienLevel(_aienId);
    }
}

