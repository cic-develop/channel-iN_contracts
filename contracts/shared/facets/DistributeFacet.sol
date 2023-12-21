// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;

// import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
// import {IERC20} from "../../shared/interfaces/IERC20.sol";

// contract DistributeFacet {
//     //
//     //

//     function p0LvUpDistribute(
//         address _agency,
//         uint _agencyAmount,
//         address _influencer,
//         uint _influencerAmount,
//         uint _totalAmount
//     ) external {
//         AppStorage storage s = LibAppStorage.diamondStorage();
//         (
//             uint p1Amount,
//             uint p2Amount,
//             uint burnAmount,
//             uint teamAmountForUsdt,
//             uint p2AmountForUsdt
//         ) = distributeCalc(_totalAmount);
//         address memory per = s.contracts["per"];

//         IERC20(per).transfer(_agency, _agencyAmount);
//         IERC20(per).transfer(_influencer, _influencerAmount);
//         IERC20(per).transfer(s.contracts["burn"], burnAmount);
//         IERC20(per).transfer(s.contracts["p2"], p2Amount);
//         IERC20(per).transfer(s.contracts["p1"], p1Amount);

//         // IERC20(PER).transfer(P1, )
//         // 추가 되어야할 것들
//         // 1.P1 10% PER
//         // 2.P2 20% PER
//         // 3.Burn 1% PER
//         beforeP2Per += p2Amount;
//         beforeP2Usdt += p2AmountForUsdt;
//         beforeTeamUsdt += teamAmountForUsdt;
//     }

//     function distributeCalc(
//         uint _amount
//     ) public view returns (uint, uint, uint, uint, uint) {
//         uint _p1Amount = (_amount * 10) / 100;
//         uint _p2Amount = (_amount * 20) / 100;
//         uint _burnAmount = (_amount * 1) / 100;
//         uint _teamAmountForUsdt = (_amount * 9) / 100;
//         uint _p2AmountForUsdt = (_amount * 50) / 100;
//         return (
//             _p1Amount,
//             _p2Amount,
//             _burnAmount,
//             _teamAmountForUsdt,
//             _p2AmountForUsdt
//         );
//     }

//     // function exchangeWithDistribute() public onlyOwner {
//     //     IEstimate(KLAYSWAP_Util).estimateSwap(PER, );
//     // 	//
//     // 	//
//     // 	//
//     // 	//
//     // }

//     function getDistributePrice() external view returns (uint, uint, uint) {
//         return (beforeP2Usdt, beforeP2Per, beforeTeamUsdt);
//     }

//     function exit() external onlyOwner returns (uint, uint, uint) {
//         IERC20(PER).transfer(msg.sender, beforeP2Usdt + beforeTeamUsdt);
//         uint _beforeP2Usdt = beforeP2Usdt;
//         uint _beforeP2Per = beforeP2Per;
//         uint _beforeTeamUsdt = beforeTeamUsdt;

//         beforeP2Usdt = 0;
//         beforeP2Per = 0;
//         beforeTeamUsdt = 0;

//         return (_beforeP2Usdt, _beforeP2Per, _beforeTeamUsdt);
//     }
// }
