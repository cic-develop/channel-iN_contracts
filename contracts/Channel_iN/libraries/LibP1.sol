// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";

library LibP1 {
    // events
    event MixCall(
        uint indexed _tokenId,
        uint indexed _mixType,
        bool indexed isLevelUp,
        uint price
    );
    event MergeToMint(
        address indexed _to,
        uint indexed _PerFriends_id,
        uint indexed _Use_item_id,
        uint _usePerAmount,
        bytes _pfURI
    );

    function _baseMixCall(address _sender, uint _id, uint _useItemId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IERC721(s.contracts["aien"].ownerOf(_id)) == _sender,
            "not owner"
        );
    }

    function _premiumMixCall() internal {}

    function _itemMerge(
        address _sender,
        uint _itemId,
        uint _itemAmount
    ) internal {}

    function _addProbCall(uint _aienId, uint[] memory _pf_Ids) internal {}

    // internal functions
    function __random(address _sender) internal returns (uint) {
        // if (s.orakl  ? oraklVRF() : nativeRF())
        bytes32 hash = keccak256(
            abi.encodePacked(block.timestamp, _sender, block.coinbase)
        );
        return (uint(hash) % (maxProb - 0 + 1)) + 0;
    }

    function __randomAddProb(
        address _sender,
        uint _max,
        uint _min
    ) internal returns (uint) {
        // if (s.orakl  ? oraklVRF() : nativeRF())
        bytes32 hash = keccak256(
            abi.encodePacked(block.timestamp, _sender, block.coinbase)
        );
        return (uint(hash) % (_max - _min + 1)) + _min;
    }

    function __checkDuplicates(
        uint[] memory array
    ) internal pure returns (bool) {
        for (uint i = 0; i < array.length - 1; i++) {
            for (uint j = i + 1; j < array.length; j++) {
                if (array[i] == array[j]) return true;
            }
        }
        return false;
    }

    // 다중 ERC721 owner확인
    function __checkERC721sOwner(
        address _owner,
        address _contract,
        uint[] memory _ids
    ) internal view returns (bool) {
        for (uint i = 0; i < _ids.length; i++) {
            if (IERC721(_contract).ownerOf(_ids[i]) != _owner) return false;
        }
        return true;
    }

    // 다중 ERC721의 등급별 mixPFInfos 합을 구한다.
    function __checkERC721sGrade(
        uint[] memory _ids
    ) internal view returns (uint) {
        uint _gradeProb = 0;
        for (uint i = 0; i < _ids.length; i++) {
            _gradeProb += mixPFInfos[IDB(DB).PFS(_ids[i]).class].gradeProb;
        }
        return _gradeProb;
    }
}
