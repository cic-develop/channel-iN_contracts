// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "./LibAppStorage.sol";
import {LibDiamond} from "./LibDiamond.sol";
import {LibMeta} from "./LibMeta.sol";
import {LibP2} from "../../Channel_iN/libraries/LibP2.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IKlaySwap} from "../interfaces/IKlaySwap.sol";
import {IP2} from "../../Channel_iN/interfaces/IP2.sol";
import {IP1} from "../../Channel_iN/interfaces/IP1.sol";

library LibDistribute {
    //
    //
    // ─── P0 LV UP DISTRIBUTION ─────────────────────────────────────────────────────
    function p0LvUpDistribute(
        address _agency,
        uint _agencyAmount,
        address _influencer,
        uint _influencerAmount,
        uint _totalAmount
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        (
            uint p1Amount,
            uint p2BaseAmount,
            uint p2PlusAmount,
            uint burnAmount,
            uint teamFeeAmount
        ) = distributeCalc(_totalAmount);
        address per = s.contracts["per"];

        IERC20(per).transfer(_agency, _agencyAmount);
        IERC20(per).transfer(_influencer, _influencerAmount);
        IERC20(per).transfer(s.contracts["p1"], p1Amount);
        IERC20(per).transfer(s.contracts["p2balance"], p2BaseAmount+ p2PlusAmount);
        IERC20(per).transfer(s.contracts["burn"], burnAmount);
        IERC20(per).transfer(s.contracts["team"], teamFeeAmount);

        // // LibP2._P2_Add_Base_Distribution(p2Amount, 0);
        LibP2._P2_Add_Base_Distribution(p2BaseAmount, 0);
        LibP2._P2_Add_Plus_Distribution(p2PlusAmount);
        IP1(s.contracts["p1"]).diamond_P1_addDistributionAmountAll(p1Amount);
        // // IERC20(PER).transfer(P1, )
        // // 추가 되어야할 것들
        // // 1.P1 10% PER
        // // 2.P2 20% PER
        // // 3.Burn 1% PER
        // s.distribute_states.beforeP2Per += p2Amount;
        // s.distribute_states.beforeP2Usdt += p2AmountForUsdt;
        // s.distribute_states.beforeTeamUsdt += teamAmountForUsdt;
    }

    function distributeCalc(
        uint _amount
    ) internal view returns (uint, uint, uint, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint _p1Amount = (_amount * s.distribute_states.p1Ratio) / 100;
        uint _p2BaseAmount = (_amount * s.distribute_states.p2BaseRatio) / 100;
        uint _p2PlusAmount = (_amount * s.distribute_states.p2PlusRatio) /
            100;
        uint _burnAmount = (_amount * s.distribute_states.burnRatio) / 100;
        uint _teamFeeAmount = (_amount *
            s.distribute_states.teamFeeRatio) / 100;
        return (
            _p1Amount,
            _p2BaseAmount,
            _p2PlusAmount,
            _burnAmount,
            _teamFeeAmount
        );
    }

    // function swapToDistribute() internal {
    //     (bool run, uint thisBalance, uint estimateUsdt) = isSwap();
    //     require(run == true, "swapToDistribute: swap is not needed");
    //     AppStorage storage s = LibAppStorage.diamondStorage();

    //     address[] memory path;

    //     IERC20(s.contracts["per"]).approve(
    //         s.contracts["klayswap"],
    //         thisBalance
    //     );

    //     IKlaySwap(s.contracts["klayswap"]).exchangeKctPos(
    //         s.contracts["per"],
    //         thisBalance,
    //         s.contracts["usdt"],
    //         estimateUsdt,
    //         path
    //     );

    //     _swapToCalculate();
    // }

    // function _swapToCalculate() internal returns (uint, uint, uint) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     uint usdtBalance = IERC20(s.contracts["usdt"]).balanceOf(address(this));
    //     uint calculatePercent = s.distribute_states.p2UsdtRatio +
    //         s.distribute_states.teamUsdtRatio;

    //     uint _p2UsdtAmount = (usdtBalance * s.distribute_states.p2UsdtRatio) /
    //         calculatePercent;
    //     uint _teamUsdtAmount = (usdtBalance *
    //         s.distribute_states.teamUsdtRatio) / calculatePercent;

    //     IERC20(s.contracts["per"]).transfer(s.contracts["p2balance"], _p2UsdtAmount);

    //     IERC20(s.contracts["per"]).transfer(
    //         s.contracts["team"],
    //         _teamUsdtAmount
    //     );

    //     IP2(s.contracts["p2balance"]).addPerUsdtDistribution(_p2UsdtAmount, 0);

    //     s.distribute_states.beforeP2Per = 0;
    //     s.distribute_states.beforeP2Usdt = 0;
    //     s.distribute_states.beforeTeamUsdt = 0;
    // }

    // function getDistributePrice() internal view returns (uint, uint, uint) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     return (
    //         s.distribute_states.beforeP2Usdt,
    //         s.distribute_states.beforeTeamUsdt,
    //         s.distribute_states.beforeP2Per
    //     );
    // }

    function isSwap() internal view returns (bool, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address[] memory path;
        uint _balance = IERC20(s.contracts["per"]).balanceOf(address(this));

        uint estimateUsdt = IKlaySwap(s.contracts["klayswaputil"]).estimateSwap(
            s.contracts["per"],
            s.contracts["per"],
            _balance,
            path
        );

        if (estimateUsdt > s.ksSwapLimit && s.isAutoDistribute == true) {
            return (true, _balance, estimateUsdt);
        } else {
            return (false, 0, 0);
        }
    }
}
