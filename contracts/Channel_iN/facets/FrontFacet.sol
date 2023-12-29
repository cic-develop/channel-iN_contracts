// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC1155} from "../../shared/interfaces/IERC1155.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

/**
@dev get load BlockChain datas before front component mount
 */
contract FrontFacet {
    function isApprovedAsset(
        address _user
    ) external view returns (bool, bool, bool, bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        return (
            // per
            IERC20(s.contracts["per"]).allowance(
                _user,
                s.contracts["diamond"]
            ) > 0,
            // aien
            IERC721(s.contracts["aien"]).isApprovedForAll(
                _user,
                s.contracts["diamond"]
            ),
            // 퍼프
            IERC721(s.contracts["perfriends"]).isApprovedForAll(
                _user,
                s.contracts["diamond"]
            ),
            // item
            IERC1155(s.contracts["item"]).isApprovedForAll(
                _user,
                s.contracts["diamond"]
            )
        );
    }

    
}
