// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibDiamond} from "./LibDiamond.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibMeta} from "./LibMeta.sol";
// using EnumerableSet for EnumerableSet.AddressSet;
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

// Market Struct
struct Market_Collection {
    address nftAddress;
    address creator;
    string name;
    string symbol;
    uint8 nftType;
    uint floorPrice;
    uint8 tradeFeeRatio;
    bool isOpen;
    //
    uint totalTradeBalance;
    uint totalTradeCount;
}

struct Market_Nft {
    address owner;
    uint tokenId;
    uint latestPrice;
}

// struct Market_Nft_History {

// }

struct Market_Nft_Order {
    uint orderId;
    address orderer;
    uint8 orderType;
    uint24 orderQuantity;
    uint orderPrice;
    uint orderTime;
    uint orderExpireTime;
}

struct Market_Activity {
    uint orderId;
    address from;
    address to;
    uint8 activityType;
    uint activityTime;
    uint activityAmount;
    uint activityPrice;
    bytes32 activityTxHash;
}

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
    // MarketStructs
    mapping(address => Market_Collection) market_collections;
    mapping(uint => Market_Nft) market_nfts;
    mapping(uint => Market_Nft_Order) market_nft_orders;
    mapping(uint => Market_Nft_Order[]) market_nft_order_history;
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    // function marketStorage() internal pure returns (MarketStorage storage ds) {
    //     bytes32 position = keccak256("diamond.standard.market.storage");
    //     assembly {
    //         ds.slot := position
    //     }
    // }

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

    // modifier checkRole(uint16 _role) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     require(
    //         s.roles[_role].accounts.contains(LibMeta.msgSender()),
    //         "AccessControl: sender does not have required role"
    //     );
    //     _;
    // }
}
