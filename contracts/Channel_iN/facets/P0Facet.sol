// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {LibP0} from "../libraries/LibP0.sol";

interface IP0 {
    function mixPFInfos(
        uint _level
    ) external view returns (string memory, uint);
}

/**
@dev i-TEZ : P0 (Mix) Facet Contract
 */
contract P0Facet is Modifiers {
    function P0_itemMerge(uint _itemId, uint _itemAmount) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        LibP0._itemMerge(msgsender, _itemId, _itemAmount);
    }

    function P0_baseMixCall(uint _id, uint _useItemId) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        return LibP0._baseMixCall(msgsender, _id, _useItemId);
    }

    function P0_premiumMixCall(
        uint _id,
        uint _useItemId
    ) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        LibP0._premiumMixCall(msgsender, _id, _useItemId);
    }

    function P0_addProbCall(
        uint _aienId,
        uint[] memory _pf_Ids
    ) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        LibP0._addProbCall(msgsender, _aienId, _pf_Ids);
    }

    /**
    P0 _ get functions
     */

    function P0_getMaxProb() external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.p0_states.maxProb;
    }

    // input ItemId별로 병합시 소요되는 Per, item수량
    function P0_getMergeState(uint _itemId) external view returns (uint, uint) {
        return LibP0._getMergeState(_itemId);
    }

    // PF POWER ZONE 사용되는 Per 수량
    function P0_getAddProbFee() external view returns (uint) {
        return LibP0._getAddProbFee();
    }

    // 인플루언서 루비온 병합시 amount
    function P0_influencerMergeAmount() external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["db"]).influencerMergeAmount();
    }

    // 재단 루비온 병합시 amount
    function P0_basicMergeAmount() external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["db"]).basicMergeAmount();
    }

    // MixPFInfos
    function P0_mixPFInfos(
        uint _level
    ) external view returns (string memory, uint) {
        return IP0(s.contracts["p0"]).mixPFInfos(_level);
    }
}
