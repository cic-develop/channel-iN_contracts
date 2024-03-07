// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {LibAppStorage, AppStorage, P2_Layer,P2_Aien,P2_User} from "../../shared/libraries/LibAppStorage.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IDB} from "../interfaces/IDB.sol";

// libs
import "../../shared/libraries/LibEnumerableSet.sol";

library LibP2 {
    using EnumerableSet for EnumerableSet.UintSet;

    struct AienLoadData {
		//aien정보
		uint _aienId;
		uint _aienLevel;
		// 출금 토탈
		uint _aien_base_received;
		uint _aien_plus_received;
		//출금 가능
		uint base_withdrawable;
		uint plus_withdrawable;
		// block당 리워드
		uint block_reward_base;
		uint block_reward_plus;
	}

	struct LayerLoadData {
		bool isOpen;
		uint _layerNumber;
		uint _24h_reward_base;
		uint _24h_reward_plus;
		uint totalStakedAien;
	}
	struct UserLoadData {
		uint _baseRewarded;
		uint _plusRewarded;
		bool _isBlockUser;
	}

    modifier isOpenLayer(uint _layer) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.p2_layers[_layer].isOpen, "P2: Layer is not open");
        _;
    }

    modifier isBlackUser() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(!s.p2_users[msg.sender].isBlockUser, "P2: BlackList User");
        _;
    }

    modifier isP2StopCheck() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(!s.isP2Stop, "P2: P2 is stopped");
        _;
    }

    modifier isMaxStakingLimit() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.p2_users[msg.sender].tokenIds.length() < s.P2_MAX_STAKING_LIMIT, "P2: Max Staking Limit");
        _;
    }

    
    // function _P2_Start(uint _baseBalance, uint _plusBalance, uint _dailyRewardPercent,uint _maxStakingLimit) internal returns(bool){
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     s.isP2Stop = true;
    //     s.REWARD_PERCENT_DECIMAL = 1e5;
    //     s.PRECISION_FACTOR = 1e12;
    //     s.DAY_TO_SEC = 86400;
    //     s.P2_baseBalance = _baseBalance;
    //     s.P2_plusBalance = _plusBalance;
    //     s.P2_dailyRewardPercent = _dailyRewardPercent;
    //     s.P2_dailyRewardUpdateBlock = block.number - 86400;
    //     s.P2_MAX_STAKING_LIMIT = _maxStakingLimit;

    //     return true;
    // }

    // function _P2_Layer_Setting(
    //     uint _layerNumber,
	// 	uint _fromP2PlusPercent,
	// 	uint _fromP2BasePercent,
	// 	uint _dailyReward_Percent,
	// 	uint _add_dailyReward_Percent,
	// 	bool _isOpen
    //     ) internal returns(bool){
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     s.p2_layers[_layerNumber].rewardPlusPercent = _fromP2PlusPercent;
    //     s.p2_layers[_layerNumber].rewardBasePercent = _fromP2BasePercent;
    //     s.p2_layers[_layerNumber].dailyReward_Percent = _dailyReward_Percent;
    //     s.p2_layers[_layerNumber].add_dailyReward_Percent = _add_dailyReward_Percent;
    //     s.p2_layers[_layerNumber].isOpen = _isOpen;
        
    //     return true;
    // }

    // function _P2_Layer_Balances_Setting(uint _layerNumber, uint _baseBalance,uint _plusBalance, uint _savedBaseBalance,uint _savedPlusBalance) internal returns(bool){
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     s.p2_layers[_layerNumber].balances.baseBalance = _baseBalance;
    //     s.p2_layers[_layerNumber].balances.plusBalance = _plusBalance;
    //     s.p2_layers[_layerNumber].balances.savedBaseBalance = _savedBaseBalance;
    //     s.p2_layers[_layerNumber].balances.savedPlusBalance = _savedPlusBalance;

    //     return true;
    // }

    function _P2_Layer_Reset(uint _layerNumber) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        
        s.p2_layers[_layerNumber].dailyRewardUpdateBlock = block.number;
        s.p2_layers[_layerNumber].lastRewardBlock = block.number;

        s.p2_layers[_layerNumber].balances.savedBaseBalance += s.p2_layers[_layerNumber].balances.baseBalance;
        s.p2_layers[_layerNumber].balances.savedPlusBalance += s.p2_layers[_layerNumber].balances.plusBalance;

        (uint dailyBASE, uint dailyPLUS) = __P2_Daily_Calculate(s.P2_baseBalance,s.P2_plusBalance, s.P2_dailyRewardPercent);
        (uint add_dailyBASE, uint add_dailyPLUS) = __P2_Daily_Calculate(
            s.p2_layers[_layerNumber].balances.savedBaseBalance, 
            s.p2_layers[_layerNumber].balances.savedPlusBalance, 
            s.p2_layers[_layerNumber].add_dailyReward_Percent
        );
        
        s.p2_layers[_layerNumber].balances.savedBaseBalance -= add_dailyBASE;
        s.p2_layers[_layerNumber].balances.savedPlusBalance -= add_dailyPLUS;

        s.p2_layers[_layerNumber].balances.baseBalance = 
        ((dailyBASE / s.REWARD_PERCENT_DECIMAL) * s.p2_layers[_layerNumber].rewardBasePercent) + 
        add_dailyBASE;

        s.p2_layers[_layerNumber].balances.plusBalance = 
        ((dailyPLUS / s.REWARD_PERCENT_DECIMAL) * s.p2_layers[_layerNumber].rewardPlusPercent) +
        add_dailyPLUS;

        __P2_Layer_Update(_layerNumber);
    }


    function _P2_Add_Base_Distribution(uint _base, uint _plus) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.P2_baseBalance += _base;
        s.P2_plusBalance += _plus;

        __P2_Update();
    }

    function _P2_Add_Plus_Distribution(uint _plus) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.P2_plusBalance += _plus;

        __P2_Update();
    }

    function __P2_Update() internal isP2StopCheck() returns (uint){
        AppStorage storage s = LibAppStorage.diamondStorage();

        if(s.P2_dailyRewardUpdateBlock == block.number) return block.number;

        if(block.number > s.P2_dailyRewardUpdateBlock + s.DAY_TO_SEC ) {

            uint distri_base = 0;
            uint distri_plus = 0;


            while(block.number > s.P2_dailyRewardUpdateBlock + s.DAY_TO_SEC){
                s.P2_dailyRewardUpdateBlock += s.DAY_TO_SEC;
                (uint dailyBASE, uint dailyPLUS) = __P2_Daily_Calculate(s.P2_baseBalance,s.P2_plusBalance, s.P2_dailyRewardPercent);
                
                for(uint8 i = 1; i < 11; i++){
                    (uint add_dailyBASE, uint add_dailyPLUS) = __P2_Daily_Calculate(
                        s.p2_layers[i].balances.savedBaseBalance,
                        s.p2_layers[i].balances.savedPlusBalance,
                        s.p2_layers[i].add_dailyReward_Percent
                    );
                distri_base = (dailyBASE / s.REWARD_PERCENT_DECIMAL) * s.p2_layers[i].rewardBasePercent;
                distri_plus = (dailyPLUS / s.REWARD_PERCENT_DECIMAL) * s.p2_layers[i].rewardPlusPercent;

                if(!s.p2_layers[i].isOpen){
                    s.p2_layers[i].balances.baseBalance = 0;
                    s.p2_layers[i].balances.plusBalance = 0;
                    s.p2_layers[i].balances.savedBaseBalance += ((dailyBASE / s.REWARD_PERCENT_DECIMAL) * 
                    s.p2_layers[i].rewardBasePercent);
                    s.p2_layers[i].balances.savedPlusBalance += ((dailyPLUS / s.REWARD_PERCENT_DECIMAL) *
                    s.p2_layers[i].rewardPlusPercent);

                continue;

                }

                s.p2_layers[i].balances.savedBaseBalance -= add_dailyBASE;
                s.p2_layers[i].balances.savedPlusBalance -= add_dailyPLUS;

                s.p2_layers[i].balances.baseBalance = 
                ((dailyBASE / s.REWARD_PERCENT_DECIMAL) * s.p2_layers[i].rewardBasePercent) +
                add_dailyBASE;

                s.p2_layers[i].balances.plusBalance = 
                ((dailyPLUS / s.REWARD_PERCENT_DECIMAL) * s.p2_layers[i].rewardPlusPercent) +
                add_dailyPLUS;

            }
            //분배 되어야할 dailyReward 차감
            s.P2_baseBalance -= distri_base;
            s.P2_plusBalance -= distri_plus;
            }
        }
        return block.number;
    }

    function __P2_Layer_Update(uint _layerNumber) internal isOpenLayer(_layerNumber) returns (uint){
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.p2_layers[_layerNumber].isOpen, "P2: Layer is not open");
        P2_Layer storage layer = s.p2_layers[_layerNumber];
        
        uint accRewardBase = 0;
        uint accRewardPlus = 0;

        if(layer.lastRewardBlock == block.number) return block.number;
        if(layer.totalStakedAien == 0) return block.number;

        if(block.number > layer.dailyRewardUpdateBlock + s.DAY_TO_SEC){
            while(block.number > layer.dailyRewardUpdateBlock + s.DAY_TO_SEC){
                layer.dailyRewardUpdateBlock += s.DAY_TO_SEC;

                // acc = 남은블록의 리워드 * 데일리 리워드 퍼센트                
                accRewardBase = ((layer.dailyRewardUpdateBlock - layer.lastRewardBlock) *
                (layer.balances.baseBalance / s.DAY_TO_SEC) *
                ((layer.dailyReward_Percent * s.PRECISION_FACTOR)/s.REWARD_PERCENT_DECIMAL));
                
                layer.rewardBase += accRewardBase / layer.totalStakedAien;
                

                // acc = 남은블록의 리워드 * 데일리 리워드 퍼센트
                accRewardPlus = ((layer.dailyRewardUpdateBlock - layer.lastRewardBlock) *
                (layer.balances.plusBalance / s.DAY_TO_SEC) *
                ((layer.dailyReward_Percent * s.PRECISION_FACTOR)/s.REWARD_PERCENT_DECIMAL));

                layer.rewardPlus += accRewardPlus / layer.totalStakedAien;

                ///////////// 
                layer.lastRewardBlock = layer.dailyRewardUpdateBlock;
            }
        }

        accRewardBase = ((block.number - layer.lastRewardBlock) *
        (layer.balances.baseBalance / s.DAY_TO_SEC) *
        ((layer.dailyReward_Percent * s.PRECISION_FACTOR)/s.REWARD_PERCENT_DECIMAL));
        layer.rewardBase += accRewardBase / layer.totalStakedAien;


        accRewardPlus = ((block.number - layer.lastRewardBlock) *
        (layer.balances.plusBalance / s.DAY_TO_SEC) *
        ((layer.dailyReward_Percent * s.PRECISION_FACTOR)/s.REWARD_PERCENT_DECIMAL));
        layer.rewardPlus += accRewardPlus / layer.totalStakedAien;
        /////////////
        layer.lastRewardBlock = block.number;

        return block.number;
    }

    function __P2_Pending_Reward(uint _aienId, uint _layerNumber) internal view returns (uint, uint){
        AppStorage storage s = LibAppStorage.diamondStorage();
        P2_Layer memory layer = s.p2_layers[_layerNumber];
        P2_Aien memory aien = s.p2_aiens[_aienId];
        if(layer.totalStakedAien == 0) return (0,0);

        uint _dailyRewardUpdateBlock = layer.dailyRewardUpdateBlock;
		uint _lastRewardBlock = layer.lastRewardBlock;
		uint _rewardBase = layer.rewardBase;
		uint _rewardPlus = layer.rewardPlus;
		uint _REWARD_BASE_SUPPLY = layer.balances.baseBalance;
		uint _REWARD_PLUS_SUPPLY = layer.balances.plusBalance;
		uint accRewardBase = 0;
		uint accRewardPlus = 0;
		uint _nowBlock = block.number;

        if(_nowBlock > layer.dailyRewardUpdateBlock + s.DAY_TO_SEC){
            while(_nowBlock > _dailyRewardUpdateBlock + s.DAY_TO_SEC){
                
                _dailyRewardUpdateBlock += s.DAY_TO_SEC;

                accRewardBase = ((_dailyRewardUpdateBlock - _lastRewardBlock) *
                (_REWARD_BASE_SUPPLY / s.DAY_TO_SEC) *
                ((layer.dailyReward_Percent * s.PRECISION_FACTOR)/s.REWARD_PERCENT_DECIMAL));
                

                _rewardBase += accRewardBase / layer.totalStakedAien;
                _REWARD_BASE_SUPPLY = accRewardBase / s.PRECISION_FACTOR;

                accRewardPlus = ((_dailyRewardUpdateBlock - _lastRewardBlock) *
                (_REWARD_PLUS_SUPPLY / s.DAY_TO_SEC) *
                ((layer.dailyReward_Percent * s.PRECISION_FACTOR)/s.REWARD_PERCENT_DECIMAL));
                

                _rewardPlus += accRewardPlus / layer.totalStakedAien;
                _REWARD_PLUS_SUPPLY = accRewardPlus / s.PRECISION_FACTOR;

                _lastRewardBlock = _dailyRewardUpdateBlock;
            }
        }
        // 
        accRewardBase = ((_nowBlock - _lastRewardBlock) *
        (_REWARD_BASE_SUPPLY / s.DAY_TO_SEC) *
        ((layer.dailyReward_Percent * s.PRECISION_FACTOR) / s.REWARD_PERCENT_DECIMAL));

        _rewardBase += accRewardBase / layer.totalStakedAien;
        // 
        accRewardPlus = ((_nowBlock - _lastRewardBlock) *
        (_REWARD_PLUS_SUPPLY / s.DAY_TO_SEC) *
        ((layer.dailyReward_Percent * s.PRECISION_FACTOR) / s.REWARD_PERCENT_DECIMAL));

        _rewardPlus += accRewardPlus / layer.totalStakedAien;  
        // 

        uint totalRewardBase = _rewardBase - aien.rewardBaseDebt;
        uint totalRewardPlus = _rewardPlus - aien.rewardPlusDebt;

        return (totalRewardBase / s.PRECISION_FACTOR, totalRewardPlus / s.PRECISION_FACTOR);
    }

    // 
    // 
    // 

    function __P2_Daily_Calculate(uint _baseBalance, uint _plusBalance, uint _dailyRewardPercent) internal pure returns(uint,uint) {
        uint dailyBASE = (_baseBalance * _dailyRewardPercent) / 1e5;
        uint dailyPLUS = (_plusBalance * _dailyRewardPercent) / 1e5;

        return (dailyBASE, dailyPLUS);
    }


    function __P2_Reward_Transfer(address _to, uint _base, uint _plus) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
		IERC20(s.contracts["per"]).transfer(_to, _base);
        IERC20(s.contracts["per"]).transfer(_to, _plus);
    }

    function __P2_Aien_Transfer(address _staker, uint _aienId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        IERC721(s.contracts["aien"]).safeTransferFrom(address(this), _staker, _aienId);
    }


    


    // admin Functions
    function __P2_Layer_Start(uint _layerNumber) internal {
        _P2_Layer_Reset(_layerNumber);
    }

    // user call functions
    function diamond_P2_deposit(
		address _sender,
		uint _aienId
	) internal isMaxStakingLimit() isBlackUser() isP2StopCheck() returns(uint){
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint _layer = IDB(s.contracts["db"]).getAienLevel(_aienId);
        P2_Layer storage layer = s.p2_layers[_layer];

        if(layer.totalStakedAien == 0){
            __P2_Layer_Start(_layer);
        }

        __P2_Update();
        __P2_Layer_Update(_layer);

        P2_User storage user = s.p2_users[_sender];
        P2_Aien storage aien = s.p2_aiens[_aienId];

        user.tokenIds.add(_aienId);

        aien.staker = _sender;
        aien.level = _layer;

        layer.totalStakedAien += 1;

        aien.rewardBaseDebt = layer.rewardBase;
        aien.rewardPlusDebt = layer.rewardPlus;

        return block.number;
    }

        
    function diamond_P2_withdraw(
        address _sender,
		uint _aienId) internal isBlackUser() isP2StopCheck() returns(uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        P2_User storage user = s.p2_users[_sender];
        P2_Aien storage aien = s.p2_aiens[_aienId];
        P2_Layer storage layer = s.p2_layers[aien.level];

        uint pendingBASE;
        uint pendingPLUS;

        __P2_Update();
        __P2_Layer_Update(aien.level);

        (pendingBASE, pendingPLUS) = __P2_Pending_Reward(_aienId, aien.level);


        __P2_Reward_Transfer(aien.staker, pendingBASE, pendingPLUS);

        user.baseRewarded += pendingBASE;
        user.plusRewarded += pendingPLUS;
        
        aien.base_received += pendingBASE;
        aien.plus_received += pendingPLUS;
        
        user.tokenIds.remove(_aienId);

        layer.totalStakedAien -= 1;

        if(layer.totalStakedAien == 0){
        layer.dailyRewardUpdateBlock = 0;
        layer.lastRewardBlock = 0;
        layer.balances.add_dailyBASE = 0;
        layer.balances.add_dailyPLUS = 0;

        layer.rewardBase = 0;
        layer.rewardPlus = 0;
        }

        aien.rewardBase += pendingBASE;
        aien.rewardPlus += pendingPLUS;
        aien.rewardBaseDebt = layer.rewardBase;
        aien.rewardPlusDebt = layer.rewardPlus;

        __P2_Aien_Transfer(aien.staker, _aienId);

        aien.staker = address(0);

        return block.number;
    }

    function diamond_P2_harvest(address _sender, uint _aienId) isP2StopCheck() internal returns (uint){
        AppStorage storage s = LibAppStorage.diamondStorage();
        P2_User storage user = s.p2_users[_sender];
        P2_Aien storage aien = s.p2_aiens[_aienId];
        P2_Layer storage layer = s.p2_layers[aien.level];

        uint pendingBASE;
        uint pendingPLUS;

        __P2_Update();
        __P2_Layer_Update(aien.level);

        (pendingBASE, pendingPLUS) = __P2_Pending_Reward(_aienId, aien.level);

        __P2_Reward_Transfer(_sender, pendingBASE, pendingPLUS);

        user.baseRewarded += pendingBASE;
        user.plusRewarded += pendingPLUS;
        
        aien.rewardBaseDebt = layer.rewardBase;
        aien.rewardPlusDebt = layer.rewardPlus;

        aien.rewardBase += pendingBASE;
        aien.rewardPlus += pendingPLUS;

        aien.base_received += pendingBASE;
        aien.plus_received += pendingPLUS;

        return block.number;
    }



// view data
    function diamond_P2_getUserInfo(address _user) internal view returns (UserLoadData memory, AienLoadData[] memory, LayerLoadData[] memory){
        AppStorage storage s = LibAppStorage.diamondStorage();
        P2_User storage user = s.p2_users[_user];
        UserLoadData memory _UserLoadData = UserLoadData(
            user.baseRewarded,
            user.plusRewarded,
            user.isBlockUser
        );

        AienLoadData[] memory _AienLoadData = new AienLoadData[](user.tokenIds.length());
		LayerLoadData[] memory _LayerLoadData = new LayerLoadData[](11);

        for (uint i = 0; i < user.tokenIds.length(); i++) {
            
            P2_Aien memory aien = s.p2_aiens[user.tokenIds.at(i)];

			(uint _base, uint _plus) = __P2_Pending_Reward(user.tokenIds.at(i), aien.level);

			_AienLoadData[i]._aienId = user.tokenIds.at(i);
			_AienLoadData[i]._aienLevel = aien.level;
			_AienLoadData[i]._aien_base_received = aien.base_received;
			_AienLoadData[i]._aien_plus_received = aien.plus_received;
			_AienLoadData[i].block_reward_base =
				((s.p2_layers[aien.level].balances.baseBalance *
					s.p2_layers[aien.level].dailyReward_Percent) /
					s.REWARD_PERCENT_DECIMAL /
					s.p2_layers[aien.level].totalStakedAien) /
				s.DAY_TO_SEC;

			_AienLoadData[i].block_reward_plus =
				((s.p2_layers[aien.level].balances.plusBalance *
					s.p2_layers[aien.level].dailyReward_Percent) /
					s.REWARD_PERCENT_DECIMAL /
					s.p2_layers[aien.level].totalStakedAien) /
				s.DAY_TO_SEC;
			_AienLoadData[i].base_withdrawable = _base;
			_AienLoadData[i].plus_withdrawable = _plus;
		}

        for (uint i = 1; i < 11; i++) {
			P2_Layer memory layer = s.p2_layers[i];

			// if(layer.isOpen == false) break;
			// (uint dailyBASE, uint dailyPLUS) = __P2_Daily_Calculate(s.P2_baseBalance, s.P2_plusBalance, s.P2_dailyRewardPercent);

			(uint add_dailyBASE, uint add_dailyPLUS) = __P2_Daily_Calculate(
				layer.balances.savedBaseBalance,
				layer.balances.savedPlusBalance,
				layer.add_dailyReward_Percent
			);
			uint _totalStakedAien;
			layer.totalStakedAien == 0 ? _totalStakedAien = 1 : _totalStakedAien = layer.totalStakedAien;
			_LayerLoadData[i]._layerNumber = i;
			_LayerLoadData[i].isOpen = layer.isOpen;
			_LayerLoadData[i]._24h_reward_base =
				(((((s.P2_baseBalance * s.P2_dailyRewardPercent) / s.REWARD_PERCENT_DECIMAL) * layer.rewardBasePercent) /
					s.REWARD_PERCENT_DECIMAL) + add_dailyBASE) /
				_totalStakedAien;

			_LayerLoadData[i]._24h_reward_plus =
				(((((s.P2_plusBalance * s.P2_dailyRewardPercent) / s.REWARD_PERCENT_DECIMAL) * layer.rewardPlusPercent) /
					s.REWARD_PERCENT_DECIMAL) + add_dailyPLUS) /
				_totalStakedAien;

			_LayerLoadData[i].totalStakedAien = layer.totalStakedAien;
		}

		return (_UserLoadData, _AienLoadData, _LayerLoadData);
    }

    function diamond_p2_getLayerData(uint _layerNumber) internal view returns(uint,uint,uint){
        AppStorage storage s = LibAppStorage.diamondStorage();
        P2_Layer memory layer = s.p2_layers[_layerNumber];
        
        uint base = (layer.balances.savedBaseBalance * layer.dailyReward_Percent) / 
        s.REWARD_PERCENT_DECIMAL / 
        (layer.totalStakedAien + 1);

        uint plus = (layer.balances.savedPlusBalance * layer.dailyReward_Percent) /
        s.REWARD_PERCENT_DECIMAL /
        (layer.totalStakedAien + 1);

        return (base / s.DAY_TO_SEC, plus / s.DAY_TO_SEC, layer.totalStakedAien);
    }
    


    function onERC721Received(
		address operator,
		address from,
		uint256 tokenId,
		bytes memory data
	) internal pure returns (bytes4) {
		return bytes4(keccak256('onERC721Received(address,address,uint256,bytes)'));
	}




}

