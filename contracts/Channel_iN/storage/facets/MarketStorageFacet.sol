// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import "../structs/MarketFacetStorage.sol";

contract MarketStorageFacet {
    function MarketStorage()
        internal
        pure
        returns (MarketFacetStorage storage ds)
    {
        bytes32 position = keccak256("diamond.channelin.market.storage");
        assembly {
            ds.slot := position
        }
    }
}
