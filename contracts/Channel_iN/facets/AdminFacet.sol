// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

contract AdminFacet is Modifiers {
    //
    function contractAdd(
        string memory _name,
        address _address
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.contracts[_name] = _address;
    }
}
