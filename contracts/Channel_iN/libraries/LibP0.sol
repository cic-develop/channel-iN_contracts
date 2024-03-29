// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {User, P0_MergeState, P0_MergePfGrade, AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC1155} from "../../shared/interfaces/IERC1155.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibDistribute} from "../../shared/libraries/LibDistribute.sol";

library LibP0 {
    event P0_BaseMix_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed itemId,
        uint itemAmount,
        bool isLevelUp,
        uint payment
    );

    event P0_PremiumMix_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed itemId,
        uint itemAmount,
        bool isLevelUp,
        uint payment,
        uint usePower
    );

    event P0_ItemMerge_Event(
        address indexed to,
        uint indexed perfId,
        uint indexed itemId,
        uint itemAmount,
        uint payment,
        uint perfGrade,
        bytes perfURI
    );

    event P0_AddProb_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed payment,
        uint addProb,
        uint[] perfs
    );

    // uint payment
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
            emit P0_BaseMix_Event(
                _sender,
                _id,
                _useItemId,
                1,
                true,
                s.p0_gradeInfos[_AIEN.p2Level].mixFee
            );
            // emit MixCall(_id, 0, true, s.p0_gradeInfos[_AIEN.p2Level].mixFee);

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

        // emit MixCall(
        //     _id,
        //     0,
        //     _random <= _AIEN.baseProb,
        //     s.p0_gradeInfos[_AIEN.p2Level].mixFee
        // );
        emit P0_BaseMix_Event(
            _sender,
            _id,
            _useItemId,
            1,
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
        if (_AIEN.baseProb + _AIEN.addProb >= s.p0_states.maxProb) {
            // if (_AIEN.baseProb + _AIEN.addProb > _random) {
            totalProb = _AIEN.baseProb + _AIEN.addProb - s.p0_states.maxProb;
        }

        if (_AIEN.baseProb + _AIEN.addProb >= _random) {
            emit P0_PremiumMix_Event(
                _sender,
                _aienId,
                _useItemId,
                1,
                true,
                s.p0_gradeInfos[_AIEN.p2Level].mixFee,
                totalProb == 0 ? _AIEN.addProb : _AIEN.addProb - totalProb
            );
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
            emit P0_PremiumMix_Event(
                _sender,
                _aienId,
                _useItemId,
                1,
                false,
                s.p0_gradeInfos[_AIEN.p2Level].mixFee,
                totalProb == 0 ? _AIEN.addProb : _AIEN.addProb - totalProb
            );

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

        emit P0_ItemMerge_Event(
            _sender,
            mintPfId,
            _itemId,
            _itemAmount,
            mergeFee,
            1,
            bytes(_pfURI)
        );
    }

    function _itemGradeMerge(
        address _sender,
        uint _itemId,
        uint _itemAmount,
        uint8 _grade
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        P0_MergePfGrade storage _mergePfGrade = s.p0_mergePfGrades[_grade];
        string memory _seedHash = s.pfMetaURI[_mergePfGrade.latestId];
        require(_mergePfGrade.isOpen, "PF Grade Merge function not open");

        (
            uint _mergeFee,
            address _influencer,
            uint _influencerFee,
            address _agency,
            uint _agencyFee,
            uint _influencerItemAmount
        ) = _mergeCalculate(_itemId, _grade);

        IDB(s.contracts["db"])._mergeCount(
            _agency,
            _agencyFee,
            _influencer,
            _influencerFee
        );
        // require(
        //     _mergeFee < IERC20(s.contracts["per"]).balanceOf(_sender),
        //     "not enough per"
        // );
        // require(_itemAmount == _influencerItemAmount, "not equal item amount");
        IERC1155(s.contracts["item"]).burn(
            _sender,
            _itemId,
            _influencerItemAmount
        );

        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["distribute"],
            _mergeFee
        );

        LibDistribute.p0LvUpDistribute(
            _agency,
            _agencyFee,
            _influencer,
            _influencerFee,
            _mergeFee
        );

        IDB(s.contracts["db"])._itemMergeFromDiamond(
            _sender,
            _mergePfGrade.latestId,
            _seedHash,
            _grade
        );

        emit P0_ItemMerge_Event(
            _sender,
            _mergePfGrade.latestId,
            _itemId,
            _influencerItemAmount,
            _mergeFee,
            _grade,
            bytes(_seedHash)
        );

        _mergePfGrade.latestId += 1;
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

        LibDistribute.p0LvUpDistribute(
            s.contracts["team"],
            (s.p0_states.addProbFee * _pf_Ids.length) / 10,
            s.contracts["team"],
            0,
            s.p0_states.addProbFee * _pf_Ids.length
        );

        emit P0_AddProb_Event(
            _sender,
            _aienId,
            s.p0_states.addProbFee,
            _gradeProb,
            _pf_Ids
        );
    }

    // internal functions
    function __random(address _sender) internal view returns (uint) {
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
    ) internal view returns (uint) {
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

    function _getAddProbFee() internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["p0"]).addProbFee();
    }

    function _getMergeState(uint _itemId) internal view returns (uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        (uint PerPrice, , , , , uint ItemAmount) = IDB(s.contracts["db"])
            ._mergeCalcul(_itemId);
        return (PerPrice, ItemAmount);
    }

    function _mergeCalculate(
        uint _itemId,
        uint8 _grade
    ) internal view returns (uint, address, uint, address, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        P0_MergeState memory _mergeState = s.p0_mergeState;
        IDB.User memory _user = IDB(s.contracts["db"]).getUserFromItem(_itemId);
        P0_MergePfGrade storage _mergePfGrade = s.p0_mergePfGrades[_grade];

        address agency;
        address influencer;
        uint _influeIncome = (_mergePfGrade.mergeFee *
            _mergeState.influencerIncomePercent) / 1e5;
        uint _agencyIncome = (_mergePfGrade.mergeFee *
            _mergeState.agencyIncomePercent) / 1e5;

        _user.agency == address(0)
            ? agency = s.contracts["team"]
            : agency = _user.agency;
        influencer = _user.incomeAddr == address(0)
            ? s.contracts["team"]
            : _user.incomeAddr;

        return (
            _mergePfGrade.mergeFee,
            influencer,
            _influeIncome,
            agency,
            _agencyIncome,
            _mergePfGrade.mergeUseItemAmount
        );
    }
}
