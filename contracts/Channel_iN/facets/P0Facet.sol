// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";


contract P0Facet is Modifiers {
    function itemMerge(uint _itemId, uint _itemAmount) external {}

    // function baseMixCall(uint _id, uint _useItemId) external returns (bool) {
    //     IERC20
    // }

    function testCall(uint _aien, uint _itemId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        
    }


    function getCall() external view returns (address, address) {
        return (LibMeta.msgSender(), msg.sender);
    }

    function premiumMixCall(
        uint _id,
        uint _useItemId
    ) external returns (bool) {}

    function addProbCall(uint _aienId, uint[] memory _pf_Ids) external {}

    // internal functions
    function _random() internal returns (uint) {
        // if (s.orakl  ? oraklVRF() : nativeRF())
    }

    function _randomAddProb(uint _max, uint _min) internal returns (uint) {
        // if (s.orakl  ? oraklVRF() : nativeRF())
    }

    function checkDuplicates(uint[] memory array) internal pure returns (bool) {
        for (uint i = 0; i < array.length - 1; i++) {
            for (uint j = i + 1; j < array.length; j++) {
                if (array[i] == array[j]) return true;
            }
        }
        return false;
    }

    // 다중 ERC721 owner확인
    function checkERC721sOwner(
        address _owner,
        address _contract,
        uint[] memory _ids
    ) internal view returns (bool) {
        for (uint i = 0; i < _ids.length; i++) {
            if (IERC721(_contract).ownerOf(_ids[i]) != _owner) return false;
        }
        return true;
    }
}
