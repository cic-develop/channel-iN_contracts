// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IP2 {
    struct User {
        bool isBlockUser;
        uint perRewarded;
        uint usdtRewarded;
        EnumerableSet.UintSet tokenIds;
    }

    struct Aien {
        address staker;
        uint level;
        // requires value
        uint rewardPer;
        uint rewardUsdt;
        uint rewardUsdtDebt;
        uint rewardPerDebt;
        ////////////////////
        uint per_received;
        uint usdt_received;
    }

    struct Balances {
        // 로직상 계산에 필요한 밸런스 변수 (실제와 다를 수 있음)
        uint perBalance;
        uint usdtBalance;
        // 레이어가 오픈 되지 않은 상태에서
        // 레이어가 오픈되면 해당 레이어에 저장된 리워드를 데일리 리워드로 추가 분배하기 위한 변수
        uint savedPerBalance;
        uint savedUsdtBalance;
        // 현재 savedUsdt, savedPer를 통해 나온 데일리 리워드
        uint add_dailyUSDT;
        uint add_dailyPER;
        // 보안상 문제가 생겨
        // 예상보다 많은 withdraw를 요청하게 되는 경우
        // 지금까지 쌓인 레이어별 토탈 밸런스와
        // 지금까지 쌓인 레이어별 출금 밸런스를 비교하여
        // 출금 가능한지 체크하는 변수
        uint total_checkWithdrawPER;
        uint withdrawal_checkWithdrawPER;
        uint total_checkWithdrawUSDT;
        uint withdrawal_checkWithdrawUSDT;
    }

    struct Layer {
        Balances balances;
        // P2에서 해당 레이어에 토큰 배정 받을때 리워드 퍼센트
        uint rewardUsdtPercent;
        uint rewardPerPercent;
        // 유저에게 하루에 분배하는 리워드 퍼센트
        uint dailyReward_Percent;
        // 계산에 필요
        uint rewardPer;
        uint rewardUsdt;
        // 미오픈시 저장한 리워드를 데일리 리워드로 추가 분배하기 위한 퍼센트변수
        uint add_dailyReward_Percent;
        uint lastRewardBlock;
        uint dailyRewardUpdateBlock;
        uint totalStakedAien;
        bool isOpen;
    }

    struct AienLoadData {
        //aien정보
        uint _aienId;
        uint _aienLevel;
        // 출금 토탈
        uint _aien_per_received;
        uint _aien_usdt_received;
        //출금 가능
        uint usdt_withdrawable;
        uint per_withdrawable;
        // block당 리워드
        uint block_reward_per;
        uint block_reward_usdt;
    }

    struct LayerLoadData {
        bool isOpen;
        uint _layerNumber;
        uint _24h_reward_per;
        uint _24h_reward_usdt;
        uint totalStakedAien;
    }
    struct UserLoadData {
        uint _usdtRewarded;
        uint _perRewarded;
        bool _isBlockUser;
    }

    function aiens(uint _id) external view returns (Aien memory);

    function diamond_P2_deposit(address _sender, uint _aienId) external;

    function diamond_P2_withdraw(address _sender, uint _aienId) external;

    function diamond_P2_harvest(address _sender, uint _aienId) external;

    function diamond_P2_getUserInfo(
        address _sender
    )
        external
        view
        returns (
            UserLoadData memory,
            AienLoadData[] memory,
            LayerLoadData[] memory
        );

    function diamond_P2_getLayerData(
        uint _number
    ) external view returns (uint, uint, uint);

    function addPerUsdtDistribution(uint _usdt, uint _per) external;

    function P2_usdtBalance() external view returns (uint);

    function P2_perBalance() external view returns (uint);

    function MAX_STAKING_LIMIT() external view returns (uint);
}
