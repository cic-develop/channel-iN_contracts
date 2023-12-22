// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC1155} from "../../shared/interfaces/IERC1155.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibDistribute} from "../../shared/libraries/LibDistribute.sol";

library LibP0 {
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

    function _baseMixCall(
        address _sender,
        uint _id,
        uint _useItemId
    ) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        require(
            IERC721(s.contracts["aien"]).ownerOf(_id) == _sender,
            "not owner"
        );
        IDB.aien memory _AIEN = IDB(s.contracts["db"]).AIENS(_id);
        // P0_GradeInfo memory _gradeInfo = s.p0_gradeInfos[_AIEN.p2Level];
        // P0_GradeInfo memory _gradeInfoNext = s.p0_gradeInfos[_AIEN.p2Level + 1];

        require(s.p0_gradeInfos[_AIEN.p2Level].isOpen == true, "not open");

        (
            address _influencer,
            address _agency,
            uint _influencerFee,
            uint _agencyFee
        ) = IDB(s.contracts["db"])._levelUpCalcul(
                _useItemId,
                s.p0_gradeInfos[_AIEN.p2Level].mixFee
            );

        IERC1155(s.contracts["item"]).burn(_sender, _useItemId, 1);
        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["distribute"],
            s.p0_gradeInfos[_AIEN.p2Level].mixFee
        );

        LibDistribute.p0LvUpDistribute(
            _agency,
            _agencyFee,
            _influencer,
            _influencerFee,
            s.p0_gradeInfos[_AIEN.p2Level].mixFee
        );

        if (_AIEN.p2Level == 0) {
            IDB(s.contracts["db"])._levelUpSucess(_id, _AIEN.p2Level);
            emit MixCall(_id, 0, true, s.p0_gradeInfos[_AIEN.p2Level].mixFee);

            return true;
        }

        uint _random = __random(_sender);

        // 성공시
        if (_random <= _AIEN.baseProb) {
            // 성공률 초기화
            // 레벨 상승
            IDB(s.contracts["db"])._levelUpSucess(_id, _AIEN.p2Level);
        } else {
            // base성공률에 랜덤 성공률 추가

            uint _randomAdd = __randomAddProb(
                _sender,
                s.p0_gradeInfos[_AIEN.p2Level].failedAddProbMax,
                s.p0_gradeInfos[_AIEN.p2Level].failedAddProbMin
            );
            // 경험치 상승
            // _AIEN[_id].baseProb += _randomAdd;

            IDB(s.contracts["db"])._levelUpFailed(_id, _randomAdd);
        }

        emit MixCall(
            _id,
            0,
            _random <= _AIEN.baseProb,
            s.p0_gradeInfos[_AIEN.p2Level].mixFee
        );

        return true;
    }

    function _premiumMixCall(
        address _sender,
        uint _aienId,
        uint _useItemId
    ) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        IDB.aien memory _AIEN = IDB(s.contracts["db"]).AIENS(_aienId);

        require(_AIEN.p2Level != 0, "not premium level");
        require(s.p0_gradeInfos[_AIEN.p2Level].isOpen == true, "not open");

        (
            address _influencer,
            address _agency,
            uint _influencerFee,
            uint _agencyFee
        ) = IDB(s.contracts["db"])._levelUpCalcul(
                _useItemId,
                s.p0_gradeInfos[_AIEN.p2Level].mixFee
            );

        IERC1155(s.contracts["item"]).burn(_sender, _useItemId, 1);

        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["distribute"],
            s.p0_gradeInfos[_AIEN.p2Level].mixFee
        );

        LibDistribute.p0LvUpDistribute(
            _agency,
            _agencyFee,
            _influencer,
            _influencerFee,
            s.p0_gradeInfos[_AIEN.p2Level].mixFee
        );

        uint _random = __random(_sender);
        uint totalProb = 0;
        if (_AIEN.baseProb + _AIEN.addProb > _random) {
            totalProb = _AIEN.baseProb + _AIEN.addProb - s.p0_states.maxProb;
        }

        if (_AIEN.baseProb + _AIEN.addProb >= _random) {
            // 성공률 초기화
            // 레벨 상승
            IDB(s.contracts["db"])._successAienSet(
                _aienId,
                _AIEN.p2Level + 1,
                _AIEN.totalExp + s.p0_gradeInfos[_AIEN.p2Level].mixExp,
                _AIEN.influExp + s.p0_gradeInfos[_AIEN.p2Level].mixExp,
                s.p0_gradeInfos[_AIEN.p2Level].initBaseProb,
                totalProb
            );
        } else {
            uint _randomAdd = __randomAddProb(
                _sender,
                s.p0_gradeInfos[_AIEN.p2Level].failedAddProbMax,
                s.p0_gradeInfos[_AIEN.p2Level].failedAddProbMin
            );

            IDB(s.contracts["db"])._failedAienSet(
                _aienId,
                _AIEN.totalExp + s.p0_gradeInfos[_AIEN.p2Level].mixExp,
                _AIEN.influExp + s.p0_gradeInfos[_AIEN.p2Level].mixExp,
                _AIEN.baseProb + _randomAdd,
                totalProb
            );
        }

        emit MixCall(
            _aienId,
            1,
            _AIEN.baseProb + _AIEN.addProb >= _random,
            s.p0_gradeInfos[_AIEN.p2Level].mixFee
        );

        return true;
    }

    function _itemMerge(
        address _sender,
        uint _itemId,
        uint _itemAmount
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint mergeFee;
        address _influencer;
        uint _influencerFee;
        address _agency;
        uint _agencyFee;
        uint _influencerItemAmount;

        if (_itemId <= 50) {
            (
                mergeFee,
                _influencer,
                _influencerFee,
                _agency,
                _agencyFee,
                _influencerItemAmount
            ) = IDB(s.contracts["db"])._mergeCalcul(_itemId);
        } else {
            (
                mergeFee,
                _influencer,
                _influencerFee,
                _agency,
                _agencyFee,
                _influencerItemAmount
            ) = IDB(s.contracts["db"])._mergeCalcul2(_itemId);
        }

        require(_itemAmount == _influencerItemAmount);

        // merge 할때 카운트 적용 함수
        IDB(s.contracts["db"])._mergeCount(
            _agency,
            _agencyFee,
            _influencer,
            _influencerFee
        );
        //
        IERC1155(s.contracts["item"]).burn(_sender, _itemId, _itemAmount);

        // IERC20(PER).transferFrom(msg.sender, address(this), mergeFee);
        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["distribute"],
            mergeFee
        );

        LibDistribute.p0LvUpDistribute(
            _agency,
            _agencyFee,
            _influencer,
            _influencerFee,
            mergeFee
        );

        (uint mintPfId, string memory _pfURI) = IDB(s.contracts["db"])
            ._influencerMerge(_sender, _itemId, 0);
        emit MergeToMint(_sender, mintPfId, _itemId, mergeFee, bytes(_pfURI));
    }

    function _addProbCall(
        address _sender,
        uint _aienId,
        uint[] memory _pf_Ids
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IERC721(s.contracts["aien"]).ownerOf(_aienId) == _sender,
            "not owner"
        );

        require(__checkDuplicates(_pf_Ids) == false, "duplicate pf id");
        require(
            __checkERC721sOwner(_sender, _pf_Ids) == true,
            "not owner of perfriends"
        );
        uint _gradeProb = __checkERC721sGrade(_pf_Ids);
        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["distribute"],
            s.p0_states.addProbFee * _pf_Ids.length
        );

        for (uint i = 0; i < _pf_Ids.length; i++) {
            IERC721(s.contracts["perfriends"]).burn(_pf_Ids[i]);
            IDB(s.contracts["db"]).subPfGrades(_pf_Ids[i]);
        }

        IDB.aien memory _AIEN = IDB(s.contracts["db"]).AIENS(_aienId);
        IDB(s.contracts["db"]).setAienAll(
            _aienId,
            _AIEN.mixCount,
            _AIEN.p2Level,
            _AIEN.totalExp + (s.p0_states.addProbExp * _pf_Ids.length),
            _AIEN.influExp,
            _AIEN.baseProb,
            0,
            _AIEN.isPFid,
            _AIEN.addProb + _gradeProb
        );

        emit MixCall(
            _aienId,
            2,
            false,
            _pf_Ids.length * s.p0_states.addProbFee
        );
    }

    // internal functions
    function __random(address _sender) internal returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // if (s.orakl  ? oraklVRF() : nativeRF())
        bytes32 hash = keccak256(
            abi.encodePacked(block.timestamp, _sender, block.coinbase)
        );
        return (uint(hash) % (s.p0_states.maxProb - 0 + 1)) + 0;
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
        uint[] memory _ids
    ) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint i = 0; i < _ids.length; i++) {
            if (IERC721(s.contracts["perfriends"]).ownerOf(_ids[i]) != _owner)
                return false;
        }
        return true;
    }

    // 다중 ERC721의 등급별 mixPFInfos 합을 구한다.
    function __checkERC721sGrade(
        uint[] memory _ids
    ) internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint _gradeProb = 0;
        for (uint i = 0; i < _ids.length; i++) {
            _gradeProb += s
                .p0_perFriendsProbs[IDB(s.contracts["db"]).PFS(_ids[i]).class]
                .gradeProb;
        }
        return _gradeProb;
    }
}
