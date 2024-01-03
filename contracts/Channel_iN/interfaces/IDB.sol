// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// legacy db contract interface
interface IDB {
    struct pf {
        uint id;
        uint class;
        bool isAien;
        uint usedAienId;
    }

    struct pfGrade {
        uint normal;
        uint uncommon;
        uint rare;
        uint unique;
        uint legendary;
        uint myth;
        uint ancient;
    }

    struct aien {
        uint id;
        // 강화 횟수
        uint mixCount;
        //
        uint p2Level;
        // 토탈 경험치
        uint totalExp;
        // 미션 및, 인플루언서 활동 관련 경험치
        uint influExp;
        // 기본 확률
        uint baseProb;
        // 토탈 확률
        uint totalProb;
        // is PF
        uint isPFid;
        // 추가확률
        uint addProb;
    }

    function AIENS(uint _key) external view returns (aien memory);

    function PFS(uint _key) external view returns (pf memory);

    function getAien(uint _id) external view;

    function getPF(uint _id) external view;

    function getPfGrade(uint _id) external view returns (uint);

    function setAien(uint _id) external;

    function usePFimg(uint _aienId, uint _pfId) external;

    function setAienAll(
        uint _id,
        uint _mixCount,
        uint _p2Level,
        uint _totalExp,
        uint _influExp,
        uint _baseProb,
        uint _totalProb,
        uint _isPFid,
        uint _addProb
    ) external;

    function getContractAddr(
        string memory _name
    ) external view returns (address);

    function burnValue(uint _burnAmount) external;

    function setAienGradeInfo(uint _toGrade) external;

    function subPfGrades(uint _pfId) external;

    function setLevelUpStatus(uint _toGrade) external;

    function _failedAienSet(
        uint _id,
        uint _totalExp,
        uint _influExp,
        uint _baseProb,
        uint _addProb
    ) external;

    function _successAienSet(
        uint _id,
        uint _p2Level,
        uint _totalExp,
        uint _influExp,
        uint _baseProb,
        uint _addProb
    ) external;

    function _mergeCalcul(
        uint _itemId
    ) external view returns (uint, address, uint, address, uint, uint);

    function _mergeCalcul2(
        uint _itemId
    ) external view returns (uint, address, uint, address, uint, uint);

    function _influencerMerge(
        address _to,
        uint _itemId,
        uint _referralIncome
    ) external returns (uint, string memory);

    function _levelUpCalcul(
        uint _itemId,
        uint _fee
    ) external returns (address, address, uint, uint);

    function _levelUpSucess(uint _id, uint _p2Level) external;

    function _levelUpFailed(uint _id, uint _addProb) external;

    function _mergeCount(
        address _agency,
        uint _agencyFee,
        address _influencer,
        uint _influencerFee
    ) external;

    function usePFPower(uint _id, uint _usePower) external;

    function addProbFee() external view returns (uint);

    function PfGrades() external view returns (pfGrade memory);

    function getAienGradeInfo() external view returns (uint[] memory);

    function basicMergeAmount() external view returns (uint);

    function influencerMergeAmount() external view returns (uint);

    function _getMedataMargin() external view returns (uint, uint, uint);

    function getAienLevel(uint _aienId) external view returns (uint);
}
