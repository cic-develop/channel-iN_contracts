// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';

//lib
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';


interface IERC721 {
	function ownerOf(uint256 tokenId) external view returns (address owner);

	function getApproved(uint256 tokenId) external view returns (address operator);

	function safeTransferFrom(address from, address to, uint256 tokenId) external;

	function balanceOf(address owner) external view returns (uint256 balance);
}

interface IERC20 {
	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external;
}

interface IDB {
	function getContractAddr(string memory _name) external view returns (address);

	function getAienLevel(uint _id) external view returns (uint);
}



contract newP2 is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADDER_ROLE = keccak256('ADDER_ROLE');
    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

    struct User {
        bool isBlockUser;
        uint baseRewarded;
        uint plusRewarded;
        EnumerableSet.UintSet tokenIds;
    }

    struct Aien{
        address staker;
		uint level;
		// requires value
		uint rewardBase;
		uint rewardPlus;
		uint rewardBaseDebt;
		uint rewardPlusDebt;
		////////////////////
		uint baseReceived;
		uint plusReceived;
    }

    struct Balances {
        // 로직상 계산에 필요한 밸런스 변수 (실제와 다를 수 있음)
		uint baseBalance;
		uint plusBalance;
		// 레이어가 오픈 되지 않은 상태에서
		// 레이어가 오픈되면 해당 레이어에 저장된 리워드를 데일리 리워드로 추가 분배하기 위한 변수
		uint savedBaseBalance;
		uint savedPlusBalance;
		// 현재 savedUsdt, savedPer를 통해 나온 데일리 리워드
		uint add_dailyBaseReward;
		uint add_dailyPlusReward;
		// // 보안상 문제가 생겨
		// // 예상보다 많은 withdraw를 요청하게 되는 경우
		// // 지금까지 쌓인 레이어별 토탈 밸런스와
		// // 지금까지 쌓인 레이어별 출금 밸런스를 비교하여
		// // 출금 가능한지 체크하는 변수
		// uint total_checkWithdrawPER;
		// uint withdrawal_checkWithdrawPER;
		// uint total_checkWithdrawUSDT;
		// uint withdrawal_checkWithdrawUSDT;
    }

    struct Layer{
        Balances balances;
        // P2에서 해당 레이어에 토큰 배정 받을때 리워드 퍼센트
		uint rewardBasePercent;
		uint rewardPlusPercent;
		// 유저에게 하루에 분배하는 리워드 퍼센트
		uint dailyRewardPercent;
		// 계산에 필요
		uint rewardBase;
		uint rewardPlus;
		// 미오픈시 저장한 리워드를 데일리 리워드로 추가 분배하기 위한 퍼센트변수
		uint addDailyRewardPercent;
		uint lastRewardBlock;
		uint dailyRewardUpdateBlock;
		uint totalStakedAien;
		bool isOpen;
    }

    struct AienLoadData {
        //aien정보
		uint aienId;
		uint aienLevel;
		// 출금 토탈
		uint aienBaseReceived;
		uint aienPlusReceived;
		//출금 가능
		uint baseWithdrawable;
		uint plusWithdrawable;
		// block당 리워드
		uint blockRewardBase;
		uint blockRewardPlus;
    }

    struct LayerLoadData {
        bool isOpen;
		uint _layerNumber;
		uint _24h_reward_per;
		uint _24h_reward_usdt;
		uint totalStakedAien;
    }

    struct UserLoadData {

    }

    bool public isP2Stop;

    uint constant REWARD_PERCENT_DECIMAL = 1e5;
    uint constant PRECISION_FACTOR = 1e12;
	uint public constant DAY_TO_SEC = 86400;

    // staking variables
    uint public P2_basicBalance;
    uint public P2_plusBalance;
    uint public P2_dailyRewardPercent;
    uint public P2_dailyRewardUpdateBlock;
    uint public P2_lastRewardBlock;

    uint public MAX_STAKING_LIMIT;

    address public ContractDB;
    address public ContractPER;
    address public ContractAien;

    address public ContractDiamond;

    uint public DAY_COUNT;

    mapping(address => User) users;
    mapping(uint => Aien) public aiens;

    Layer[11] public layers;

    event Deposit(address indexed user, uint indexed aienId, uint indexed layer, uint timestamp);
	event Withdraw(address indexed user, uint indexed aienId, uint indexed layer, uint timestamp);
	// event Harvest(address indexed user, uint indexed per, uint indexed plus, uint aienId, uint timestamp);
	event BlackUser(address indexed user, bool isBlockUser, uint timestamp, string desc);


    // modifiers
    // .
    // .
    // .


    /// @custom:oz-upgrades-unsafe-allow constructor
	function initialize() public initializer {
		__AccessControl_init();
		__UUPSUpgradeable_init();
		__ReentrancyGuard_init();

		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function _P2_Start(address _dbAddr, address _perAddr, address _aienAddr, address _diamondAddr, uint _perBalance, uint _p2_dailyReward_Percent, uint _maxStake) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'P2: must have admin role to set layer');
        ContractDB = _dbAddr;
        ContractPER = _perAddr;
        ContractAien = _aienAddr;
        ContractDiamond = _diamondAddr;

        P2_balance = _perBalance;
        P2_dailyReward_Percent = _p2_dailyReward_Percent;
        MAX_STAKING_LIMIT = _maxStake;
        _grantRole(ADDER_ROLE, _diamondAddr);
    }

    function _layer_setting(uint _layerNumber, uint _fromP2BasePercent, uint _fromP2PlusPercent, uint _dailyRewardPercent, uint _dailyRewardAddPercent, bool _isOpen) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'P2: must have admin role to set layer');
        layers[_layerNumber].fromP2BasePercent = _fromP2BasePercent;
        layers[_layerNumber].fromP2PlusPercent = _fromP2PlusPercent;
        layers[_layerNumber].dailyRewardPercent = _dailyRewardPercent;
        layers[_layerNumber].dailyRewardAddPercent = _dailyRewardAddPercent;
        layers[_layerNumber].isOpen = _isOpen;
    }

    function _layer_reset(uint _layNumber) internal {

    }

    function addDistribution(uint _per) public onlyRole(ADDER_ROLE) {

    }


}