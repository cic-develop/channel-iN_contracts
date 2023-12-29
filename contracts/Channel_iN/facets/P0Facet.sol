// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {LibP0} from "../libraries/LibP0.sol";

/**
@dev i-TEZ : P0 (Mix) Facet Contract
 */
contract P0Facet is Modifiers {
    function itemMerge(uint _itemId, uint _itemAmount) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        LibP0._itemMerge(msgsender, _itemId, _itemAmount);
    }

    function baseMixCall(uint _id, uint _useItemId) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        return LibP0._baseMixCall(msgsender, _id, _useItemId);
    }

    function premiumMixCall(uint _id, uint _useItemId) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        LibP0._premiumMixCall(msgsender, _id, _useItemId);
    }

    function addProbCall(
        uint _aienId,
        uint[] memory _pf_Ids
    ) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        LibP0._addProbCall(msgsender, _aienId, _pf_Ids);
    }

    function getMaxProb() external view returns(uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.p0_states.maxProb;
    }
}
