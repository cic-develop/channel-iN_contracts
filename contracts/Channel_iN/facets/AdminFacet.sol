// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IP2} from "../interfaces/IP2.sol";
import {IP2_Admin} from "../interfaces/IP2_Admin.sol";
import {IDB} from "../interfaces/IDB.sol";
import {LibDistribute} from "../../shared/libraries/LibDistribute.sol";

contract AdminFacet is Modifiers {
    /**@dev P0 Admin functions
     */
    function admin_p0_setStates(
        uint24 _maxProb,
        uint _addProbFee,
        uint16 _addProbExp,
        bool _isVRF
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p0_states.maxProb = _maxProb;
        s.p0_states.addProbFee = _addProbFee;
        s.p0_states.addProbExp = _addProbExp;
        s.p0_states.isVRF = _isVRF;
    }

    function admin_p0_setGradeInfos(
        uint8 _gradeIndex,
        bool _isOpen,
        uint _mixFee,
        uint24 _initBaseProb,
        uint16 _mixExp,
        uint24 _failedAddProbMin,
        uint24 _failedAddProbMax
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p0_gradeInfos[_gradeIndex].isOpen = _isOpen;
        s.p0_gradeInfos[_gradeIndex].mixFee = _mixFee;
        s.p0_gradeInfos[_gradeIndex].initBaseProb = _initBaseProb;
        s.p0_gradeInfos[_gradeIndex].mixExp = _mixExp;
        s.p0_gradeInfos[_gradeIndex].failedAddProbMin = _failedAddProbMin;
        s.p0_gradeInfos[_gradeIndex].failedAddProbMax = _failedAddProbMax;
    }

    function admin_p0_setPerFriendsProb(
        uint _grade,
        string memory _pfGrade,
        uint24 _gradeProb
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p0_perFriendsProbs[_grade].pfGrade = _pfGrade;
        s.p0_perFriendsProbs[_grade].gradeProb = uint24(_gradeProb);
    }

    function admin_p0_getStates()
        external
        view
        returns (uint24, uint, uint16, bool)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.p0_states.maxProb,
            s.p0_states.addProbFee,
            s.p0_states.addProbExp,
            s.p0_states.isVRF
        );
    }

    function admin_p0_getGradeInfos(
        uint8 _gradeIndex
    ) external view returns (bool, uint, uint24, uint16, uint24, uint24) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.p0_gradeInfos[_gradeIndex].isOpen,
            s.p0_gradeInfos[_gradeIndex].mixFee,
            s.p0_gradeInfos[_gradeIndex].initBaseProb,
            s.p0_gradeInfos[_gradeIndex].mixExp,
            s.p0_gradeInfos[_gradeIndex].failedAddProbMin,
            s.p0_gradeInfos[_gradeIndex].failedAddProbMax
        );
    }

    function admin_p0_getPerFriendsProb(
        uint _grade
    ) external view returns (string memory, uint24) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.p0_perFriendsProbs[_grade].pfGrade,
            s.p0_perFriendsProbs[_grade].gradeProb
        );
    }

    function admin_p0_setMetaData(
        uint _pfId,
        uint8 _grade,
        string memory _seedHash
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.pfMetaURI[_pfId] = _seedHash;
        s.p0_mergePfGrades[_grade].setMatadataId = _pfId;

        IDB(s.contracts["db"]).adminSetMetaData(_pfId, _grade, _seedHash);
    }

    function admin_p0_setMergeGradesInfo(
        uint8 _grade,
        string memory _gradeName,
        uint _mergeFee,
        uint _mergeUseItemAmount,
        uint _latestId,
        bool _isOpen
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p0_mergePfGrades[_grade].grade = _grade;
        s.p0_mergePfGrades[_grade].gradeName = _gradeName;
        s.p0_mergePfGrades[_grade].mergeFee = _mergeFee;
        s.p0_mergePfGrades[_grade].mergeUseItemAmount = _mergeUseItemAmount;
        s.p0_mergePfGrades[_grade].latestId = _latestId;
        s.p0_mergePfGrades[_grade].isOpen = _isOpen;
    }

    function admin_p0_getMetadataMargin(
        uint8 _grade
    ) external view returns (uint, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.p0_mergePfGrades[_grade].latestId,
            s.p0_mergePfGrades[_grade].setMatadataId,
            s.p0_mergePfGrades[_grade].setMatadataId -
                s.p0_mergePfGrades[_grade].latestId
        );
    }

    /**@dev P2 Admin functions
     */
    function admin_P2_layer_setting(
        uint _layerNumber,
        uint _fromP2PerPercent,
        uint _fromP2UsdtPercent,
        uint _dailyReward_percent,
        uint _add_dailyReward_Percent,
        bool _isOpen
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        IP2_Admin(s.contracts["p2"])._layer_setting(
            _layerNumber,
            _fromP2PerPercent,
            _fromP2UsdtPercent,
            _dailyReward_percent,
            _add_dailyReward_Percent,
            _isOpen
        );
    }

    function admin_P2_blockUser(
        address _user,
        bool _isBlock,
        string memory _why
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        IP2_Admin(s.contracts["p2"]).diamond_P2_BlockUser(
            _user,
            _isBlock,
            _why
        );
    }

    function admin_P2_setMaxLimit(uint _maxLimit) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        IP2_Admin(s.contracts["p2"]).diamond_P2_setMaxLimit(_maxLimit);
    }

    /**@dev DistriBute Admin functions
     */
    function admin_distribute_setStates(
        uint24 _p1Ratio,
        uint24 _p2PerRatio,
        uint24 _p2UsdtRatio,
        uint24 _burnRatio,
        uint24 _teamUsdtRatio
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.distribute_states.p1Ratio = _p1Ratio;
        s.distribute_states.p2PerRatio = _p2PerRatio;
        s.distribute_states.p2UsdtRatio = _p2UsdtRatio;
        s.distribute_states.burnRatio = _burnRatio;
        s.distribute_states.teamUsdtRatio = _teamUsdtRatio;
    }

    function admin_distribute_userStates(
        uint _agencyIncomePercent,
        uint _influencerIncomePercent
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p0_mergeState.agencyIncomePercent = _agencyIncomePercent;
        s.p0_mergeState.influencerIncomePercent = _influencerIncomePercent;
    }

    function admin_distribute_getStates()
        external
        view
        returns (uint24, uint24, uint24, uint24, uint24, uint, uint)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.distribute_states.p1Ratio,
            s.distribute_states.p2PerRatio,
            s.distribute_states.p2UsdtRatio,
            s.distribute_states.burnRatio,
            s.distribute_states.teamUsdtRatio,
            s.p0_mergeState.agencyIncomePercent,
            s.p0_mergeState.influencerIncomePercent
        );
    }

    function admin_distribute_setAuto(bool _isAuto) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.isAutoDistribute = _isAuto;
    }

    function admin_distribute_ksSwapLimit(uint _limit) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.ksSwapLimit = _limit;
    }

    function admin_distribute_getBeforAmounts()
        external
        view
        returns (uint, uint, uint)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.distribute_states.beforeP2Usdt,
            s.distribute_states.beforeTeamUsdt,
            s.distribute_states.beforeP2Per
        );
    }

    function admin_distribute_estimate()
        external
        view
        returns (bool, uint, uint)
    {
        return LibDistribute.isSwap();
    }

    function admin_distribute_swap() external onlyDev {
        LibDistribute.swapToDistribute();
    }

    /**@dev aien mint variables
     */

    function admin_setAienMintFee(uint _mintFee) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.aienMintFee = _mintFee;
    }
}
