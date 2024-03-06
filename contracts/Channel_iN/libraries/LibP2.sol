// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {LibAppStorage, AppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IDB} from "../interfaces/IDB.sol";
// libs
import "../../shared/libraries/LibEnumerableSet.sol";

library LibP2 {
    function _P2_Start(uint _baseBalance, uint _plusBalance, uint _dailyRewardPercent,uint _maxStakingLimit) internal returns(bool){
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_states.isP2Stop = true;
        s.p2_states.REWARD_PERCENT_DECIMAL = 1e5;
        s.p2_states.DAY_TO_SEC = 86400;
        s.p2_states.P2_baseBalance = _baseBalance;
        s.p2_states.P2_plusBalance = _plusBalance;
        s.p2_states.P2_dailyRewardPercent = _dailyRewardPercent;
        s.p2_states.P2_dailyRewardUpdateBlock = block.number - 86400;
        s.p2_states.MAX_STAKING_LIMIT = _maxStakingLimit;

        return true;
    }

    function _P2_Layer_Setting(
        uint _layerNumber,
		uint _fromP2PlusPercent,
		uint _fromP2BasePercent,
		uint _dailyReward_Percent,
		uint _add_dailyReward_Percent,
		bool _isOpen
        ) internal returns(bool){
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_layers[_layerNumber].rewardPlusPercent = _fromP2PlusPercent;
        s.p2_layers[_layerNumber].rewardBasePercent = _fromP2BasePercent;
        s.p2_layers[_layerNumber].dailyReward_Percent = _dailyReward_Percent;
        s.p2_layers[_layerNumber].add_dailyReward_Percent = _add_dailyReward_Percent;
        s.p2_layers[_layerNumber].isOpen = _isOpen;
        
        return true;
    }

    function _P2_Layer_Balances_Setting(uint _layerNumber, uint _baseBalance,uint _plusBalance, uint _savedBaseBalance,uint _savedPlusBalance, uint _add_dailyBASE,uint _add_dailyPLUS) internal returns(bool){
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_layers[_layerNumber].balances.baseBalance = _baseBalance;
        s.p2_layers[_layerNumber].balances.plusBalance = _plusBalance;
        s.p2_layers[_layerNumber].balances.savedBaseBalance = _savedBaseBalance;
        s.p2_layers[_layerNumber].balances.savedPlusBalance = _savedPlusBalance;
        s.p2_layers[_layerNumber].balances.add_dailyBASE = _add_dailyBASE;
        s.p2_layers[_layerNumber].balances.add_dailyPLUS = _add_dailyPLUS;

        return true;
            //     uint total_checkWithdrawPLUS;
            // uint withdrawal_checkWithdrawPLUS;
            // uint total_checkWithdrawBASE;
            // uint withdrawal_checkWithdrawBASE;
    }

    function _P2_Layer_Reset(uint _layerNumber) internal returns(bool){
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.p2_layers[_layerNumber].dailyRewardUpdateBlock = block.number;
        s.p2_layers[_layerNumber].lastRewardBlock = block.number;

        

        return true;

    }

    function _P2_Add_Base_Distribution() internal {

    }

    function _P2_Add_Plus_Distribution() internal {

    }

    function __P2_Update(uint _block) internal returns (uint){

    }

    function __P2_Pending_Reward() internal returns (uint){

    }

    function onERC721Received(
		address operator,
		address from,
		uint256 tokenId,
		bytes memory data
	) internal pure returns (bytes4) {
		return bytes4(keccak256('onERC721Received(address,address,uint256,bytes)'));
	}


    function __P2_Reward_Transfer() internal {

    }

    function __P2_Aien_Transfer() internal {

    }

    function __P2_Daily_Calculate() internal {

    }

    function __P2_Get_LayerData() internal {

    }

    function __P2_Layer_Start() internal {

    }




}

