// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import "../../shared/interfaces/Iitem.sol";

contract RubyonFacet is Modifiers {
    //
    //
    //
    function rubyonMint(
        address _addr,
        uint _id,
        uint _amount,
        bytes memory _data
    ) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Iitem(s.contracts["item"]).mint(_addr, _id, _amount, _data);

        return true;
    }
}
