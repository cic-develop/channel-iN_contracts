// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibDiamond} from "./LibDiamond.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibMeta} from "./LibMeta.sol";

using EnumerableSet for EnumerableSet.UintSet;
// i-Tez Structs
//- P0 struct
struct P0_State {
    uint24 maxProb;
    // 퍼프렌즈를 이용한 PF POWER 변환시 개당 수수료
    uint addProbFee;
    // 퍼프렌즈를 이용한 PF POWER 변환시 획득 경험치
    uint16 addProbExp;
    // bool
    bool isVRF;
}
struct P0_PerFriendsProb {
    string pfGrade;
    uint24 gradeProb;
}

struct P0_GradeInfo {
    // 다음 level이 열렸는지 확인
    bool isOpen;
    // level별 mix fee
    uint mixFee;
    // 레벨업 성공시 level별 초기 base 확률
    uint24 initBaseProb;
    // level별 추가 확률 밸런스 조정값
    uint16 mixExp;
    // level별 합성 실패시 추가 확률 min,max
    uint24 failedAddProbMin;
    // 1000 = 0.1%, 10000 = 0.01%
    uint24 failedAddProbMax;
}

struct P0_MergePfGrade {
    uint8 grade;
    string gradeName;
    uint mergeFee;
    uint mergeUseItemAmount;
    uint latestId;
    uint setMatadataId;
    bool isOpen;
}
struct P0_MergeState {
    uint agencyIncomePercent;
    uint influencerIncomePercent;
}
// //- Distribute struct
struct Distribute_State {
    uint beforeP2Usdt;
    uint beforeP2Per;
    uint beforeTeamUsdt;
    // distribute ratios
    uint24 p1Ratio;
    uint24 p2PerRatio;
    uint24 p2UsdtRatio;
    uint24 burnRatio;
    uint24 teamUsdtRatio;
}
// DB > Filtered User Struct
struct User {
    // DB > idx
    uint userId;
    // token itme ID
    uint itemId;
    address incomeAddr;
    uint feeBalance;
    bool isAble;
    uint mintCount;
    uint useLevelupCount;
    uint useMergeCount;
    //레퍼럴로 얻은 수익
    uint referralIncome;
    address agency;
    uint agencyIncome;
}

struct P3_AienCollection {
    address nftAddress;
    string name;
    string symbol;
    uint highestPrice;
    uint floorPrice;
    uint totalTradeVolume;
    uint totalTradeCount;
}

struct P3_Aien {
    uint tokenId;
    uint lastTradePrice;
    // maybe add tx history
}

struct P3_AienOrder {
    uint orderId;
    address seller;
    address buyer;
    uint tokenId;
    uint8 level;
    uint32 baseProb;
    uint32 addProb;
    uint price;
    uint tradeTime;
    uint8 orderType;
}

struct P3_PfCollection {
    address nftAddress;
    string name;
    string symbol;
    uint highestPrice;
    uint floorPrice;
    uint totalTradeVolume;
    uint totalTradeCount;
}

struct P3_PfOrder {
    uint orderId;
    address seller;
    address buyer;
    uint tokenId;
    uint8 grade;
    uint price;
    uint tradeTime;
    uint8 orderType;
}

//
//
//
//
// P2 start
struct P2_State {
    bool isP2Stop;
    uint P2_baseBalance;
    uint P2_plusBalance;
    uint P2_dailyReward_Percent;
    uint P2_dailyRewardUpdateBlock;
    uint P2_lastRewardBlock;
    uint MAX_STAKING_LIMIT;
    uint DAYS_Count;
}
struct P2_User {
    bool isBlockUser;
    uint baseRewarded;
    uint plusRewarded;
    EnumerableSet.uintSet tokenIds;
}

struct P2_Aien {
    address staker;
    uint level;
    uint rewardBase;
    uint rewardPlus;
    uint rewardBaseDebt;
    uint rewardPlusDebt;
    //
    uint base_received;
    uint plus_received;
}

struct P2_Balances {
    uint baseBalance;
    uint plusBalance;
    uint savedBaseBalance;
    uint savedPlusBalance;
    uint add_dailyBase;
    uint add_dailyPlus;
}

struct P2_AienLoadData {
    uint _aienId;
    uint _aienLevel;
    uint _aien_base_received;
    uint _aien_plus_received;
    uint base_withdrawable;
    uint plus_withdrawable;
    uint block_reward_base;
    uint block_reward_plus;
}

struct P2_LayerLoadData {
    bool isOpen;
    uint _layerNumber;
    uint _24h_reawrd_base;
    uint _24h_reawrd_plus;
    uint totalStakedAien;
}

// P2 end

// P0 End
struct AppStorage {
    // address constants
    mapping(string => address) contracts;
    // i-Tez/////////////////////////////
    // P0 ///////////////////////////////
    P0_State p0_states;
    P0_GradeInfo[11] p0_gradeInfos;
    mapping(uint => P0_PerFriendsProb) p0_perFriendsProbs;
    /////////////////////////////////////
    // Distribute ///////////////////////
    Distribute_State distribute_states;
    uint aienMintFee;
    // Distribute
    uint ksSwapLimit;
    bool isAutoDistribute;
    // P0 - Item Merge Grade Infos
    mapping(uint8 => P0_MergePfGrade) p0_mergePfGrades;
    mapping(uint => string) pfMetaURI;
    P0_MergeState p0_mergeState;
    //////////////////////////
    // P3/////////////////////
    //
    // userAddr => orderIds;
    mapping(address => uint[]) p3_userOrders;
    //
    //
    // tokenId => orderIds;
    mapping(uint => uint[]) p3_aienTokenOrders;
    // orderId => orderInfo
    mapping(uint => P3_Aien_Order) p3_aienOrders;
    //
    // tokenId => orderIds;
    mapping(uint => uint[]) p3_pfTokenOrders;
    // orderId => orderInfo
    mapping(uint => P3_PfOrder) p3_pfOrders;
    //
    //
    //
    //
    // P2
    mapping(string => P2_State) p2_states;
    mapping(string => P2_Balances) p2_balances;
    mapping(address => P2_User) p2_users;
    mapping(uint => P2_Aien) p2_aiens;
    mapping(uint => P2_AienLoadData) p2_aienLoadDatas;
    mapping(uint => P2_LayerLoadData) p2_layerLoadDatas;
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

/**
@dev global modifier
 */
contract Modifiers {
    modifier onlyDev() {
        LibDiamond.enforceIsContractOwner();
        _;
    }
}
