// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IP2} from "../interfaces/IP2.sol";
import {IP2_Admin} from "../interfaces/IP2_Admin.sol";
import {IDB} from "../interfaces/IDB.sol";
import {LibDistribute} from "../../shared/libraries/LibDistribute.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";

import {LibP2} from "../libraries/LibP2.sol";

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
    function admin_P2_start(uint _baseBalance, uint _plusBalance, uint _dailyRewardPercent,uint _maxStakingLimit, uint _dayToSec) external onlyDev returns(bool){
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.isP2Stop = true;
        s.REWARD_PERCENT_DECIMAL = 1e5;
        s.PRECISION_FACTOR = 1e12;
        s.DAY_TO_SEC = _dayToSec;
        s.P2_baseBalance = _baseBalance;
        s.P2_plusBalance = _plusBalance;
        s.P2_dailyRewardPercent = _dailyRewardPercent;
        s.P2_dailyRewardUpdateBlock = block.number - _dayToSec;
        s.P2_MAX_STAKING_LIMIT = _maxStakingLimit;

        return true;
    } 


    function admin_P2_layer_setting(
        uint _layerNumber,
		uint _fromP2BasePercent,
		uint _fromP2PlusPercent,
		uint _add_dailyReward_Percent,
		bool _isOpen) external onlyDev {
        // 1Layer :  81144000   / 0             || -                        || 7000     ||   -      || 100000 ||
        // 2Layer :  104328000  / 0             || -                        || 9000     ||   -      || 100000 || add_dailyReward_Percent
        // 3Layer :  128491285  / 96949286      || -                        || 11000    ||   -      || 100000 || 1000
        // 4Layer :  157051365  / 629181181     || -                        || 13000    ||   -      || 100000 || 1000
        // 5Layer :  11592000   / 1528310000    || -                        || 1000     ||   -      || 100000 || 1000
        // 6Layer :  11592000   / 1528310000    || 73966502951109738390000  || 1000     || 10000    || 100000 ||
        // 7Layer :  11592000   / 1528310000    || 73966502951109738390000  || 1000     || 10000    || 100000 ||
        // 8Layer :  11592000   / 1528310000    || 73966502951109738390000  || 1000     || 10000    || 100000 ||
        // 9Layer :  11592000   / 1528310000    || 73966502951109738390000  || 1000     || 10000    || 100000 ||
        // 10Layer :  11592000  / 1528310000    || 73966502951109738390000  || 1000     || 10000    || 100000 ||

        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_layers[_layerNumber].rewardBasePercent = _fromP2BasePercent;
        s.p2_layers[_layerNumber].rewardPlusPercent = _fromP2PlusPercent;
        s.p2_layers[_layerNumber].dailyReward_Percent = 100000;
        // 1-5 layer는 0, 6-10 layer는 10000
        s.p2_layers[_layerNumber].add_dailyReward_Percent = _add_dailyReward_Percent;
        s.p2_layers[_layerNumber].isOpen = _isOpen;
    }

    function admin_P2_layer_setRewardPercent(
        uint _layerNumber,
        uint _rewardBasePercent,
        uint _rewardPlusPercent
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_layers[_layerNumber].dailyReward_Percent = _rewardBasePercent;
        s.p2_layers[_layerNumber].add_dailyReward_Percent = _rewardPlusPercent;
    }

    function admin_P2_setDailyRewardPercent(uint _dailyRewardPercent) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.P2_dailyRewardPercent = _dailyRewardPercent;
    }
    function admin_P2_blockUser(
        address _user,
        bool _isBlock
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_users[_user].isBlockUser = _isBlock;
    }

    function admin_P2_setMaxLimit(uint _maxLimit) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.P2_MAX_STAKING_LIMIT = _maxLimit;
    }    
    
    function admin_P2_layer_balances_setting(uint _layerNumber, uint _baseBalance,uint _plusBalance, uint _savedBaseBalance,uint _savedPlusBalance) external onlyDev returns(bool){
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_layers[_layerNumber].balances.baseBalance = _baseBalance;
        s.p2_layers[_layerNumber].balances.plusBalance = _plusBalance;
        s.p2_layers[_layerNumber].balances.savedBaseBalance = _savedBaseBalance;
        s.p2_layers[_layerNumber].balances.savedPlusBalance = _savedPlusBalance;

        return true;
    }

    
    function admin_P2_Stop(bool _isStop) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.isP2Stop = _isStop;
    }

    function admin_P2_setBalance(uint _baseBalance, uint _plusBalance) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.P2_baseBalance = _baseBalance;
        s.P2_plusBalance = _plusBalance;
    }



    /**@dev DistriBute Admin functions
     */
    function admin_distribute_setStates(
        uint24 _p1Ratio,
        uint24 _p2BaseRatio,
        uint24 _p2PlusRatio,
        uint24 _burnRatio,
        uint24 _teamFeeRatio
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.distribute_states.p1Ratio = _p1Ratio;
        s.distribute_states.p2BaseRatio = _p2BaseRatio;
        s.distribute_states.p2PlusRatio = _p2PlusRatio;
        s.distribute_states.burnRatio = _burnRatio;
        s.distribute_states.teamFeeRatio = _teamFeeRatio;
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
            s.distribute_states.p2BaseRatio,
            s.distribute_states.p2PlusRatio,
            s.distribute_states.burnRatio,
            s.distribute_states.teamFeeRatio,
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

    // function admin_distribute_swap() external onlyDev {
    //     LibDistribute.swapToDistribute();
    // }

    /**@dev aien mint variables
     */

    function admin_setAienMintFee(uint _mintFee) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.aienMintFee = _mintFee;
    }
}
