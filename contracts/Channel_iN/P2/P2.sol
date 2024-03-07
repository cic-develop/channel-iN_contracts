
// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

// import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
// import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
// import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
// import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';

// //lib
// import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

// // import 'hardhat/console.sol';

// interface IERC721 {
// 	function ownerOf(uint256 tokenId) external view returns (address owner);

// 	function getApproved(uint256 tokenId) external view returns (address operator);

// 	function safeTransferFrom(address from, address to, uint256 tokenId) external;

// 	function balanceOf(address owner) external view returns (uint256 balance);
// }

// interface IERC20 {
// 	function balanceOf(address account) external view returns (uint256);

// 	function transfer(address recipient, uint256 amount) external;
// }

// interface IDB {
// 	function getContractAddr(string memory _name) external view returns (address);

// 	function getAienLevel(uint _id) external view returns (uint);
// }

// contract P2 is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
// 	using EnumerableSet for EnumerableSet.UintSet;

// 	bytes32 public constant ADDER_ROLE = keccak256('ADDER_ROLE');

// 	struct User {
// 		bool isBlockUser;
// 		uint perRewarded;
// 		uint usdtRewarded;
// 		EnumerableSet.UintSet tokenIds;
// 	}

// 	struct Aien {
// 		address staker;
// 		uint level;
// 		// requires value
// 		uint rewardPer;
// 		uint rewardUsdt;
// 		uint rewardUsdtDebt;
// 		uint rewardPerDebt;
// 		////////////////////
// 		uint per_received;
// 		uint usdt_received;
// 	}

// 	struct Balances {
// 		// 로직상 계산에 필요한 밸런스 변수 (실제와 다를 수 있음)
// 		uint perBalance;
// 		uint usdtBalance;
// 		// 레이어가 오픈 되지 않은 상태에서
// 		// 레이어가 오픈되면 해당 레이어에 저장된 리워드를 데일리 리워드로 추가 분배하기 위한 변수
// 		uint savedPerBalance;
// 		uint savedUsdtBalance;
// 		// 현재 savedUsdt, savedPer를 통해 나온 데일리 리워드
// 		uint add_dailyUSDT;
// 		uint add_dailyPER;
// 		// 보안상 문제가 생겨
// 		// 예상보다 많은 withdraw를 요청하게 되는 경우
// 		// 지금까지 쌓인 레이어별 토탈 밸런스와
// 		// 지금까지 쌓인 레이어별 출금 밸런스를 비교하여
// 		// 출금 가능한지 체크하는 변수
// 		uint total_checkWithdrawPER;
// 		uint withdrawal_checkWithdrawPER;
// 		uint total_checkWithdrawUSDT;
// 		uint withdrawal_checkWithdrawUSDT;
// 	}

// 	struct Layer {
// 		Balances balances;
// 		// P2에서 해당 레이어에 토큰 배정 받을때 리워드 퍼센트
// 		uint rewardUsdtPercent;
// 		uint rewardPerPercent;
// 		// 유저에게 하루에 분배하는 리워드 퍼센트
// 		uint dailyReward_Percent;
// 		// 계산에 필요
// 		uint rewardPer;
// 		uint rewardUsdt;
// 		// 미오픈시 저장한 리워드를 데일리 리워드로 추가 분배하기 위한 퍼센트변수
// 		uint add_dailyReward_Percent;
// 		uint lastRewardBlock;
// 		uint dailyRewardUpdateBlock;
// 		uint totalStakedAien;
// 		bool isOpen;
// 	}

// 	struct AienLoadData {
// 		//aien정보
// 		uint _aienId;
// 		uint _aienLevel;
// 		// 출금 토탈
// 		uint _aien_per_received;
// 		uint _aien_usdt_received;
// 		//출금 가능
// 		uint usdt_withdrawable;
// 		uint per_withdrawable;
// 		// block당 리워드
// 		uint block_reward_per;
// 		uint block_reward_usdt;
// 	}

// 	struct LayerLoadData {
// 		bool isOpen;
// 		uint _layerNumber;
// 		uint _24h_reward_per;
// 		uint _24h_reward_usdt;
// 		uint totalStakedAien;
// 	}
// 	struct UserLoadData {
// 		uint _usdtRewarded;
// 		uint _perRewarded;
// 		bool _isBlockUser;
// 	}

// 	bool public isP2Stop;

// 	uint constant REWARD_PERCENT_DECIMAL = 1e5;
// 	uint constant PRECISION_FACTOR = 1e12;
// 	uint public constant DAY_TO_SEC = 86400;

// 	//staking variables
// 	uint public P2_usdtBalance;
// 	uint public P2_perBalance;
// 	uint public P2_dailyReward_Percent;
// 	uint public P2_dailyRewardUpdateBlock;
// 	uint public P2_lastRewardBlock;

// 	uint public MAX_STAKING_LIMIT;

// 	address public ContractDB;
// 	address public ContractPER;
// 	address public ContractUSDT;
// 	address public ContractAien;

// 	// 테스트용
// 	uint public DAYS_Count;

// 	mapping(address => User) users;
// 	mapping(uint => Aien) public aiens;

// 	//layer0은 사용하지 않음 1~10
// 	Layer[11] public layers;

// 	event Deposit(address indexed user, uint indexed aienId, uint indexed layer, uint timestamp);
// 	event Withdraw(address indexed user, uint indexed aienId, uint indexed layer, uint timestamp);
// 	event Harvest(address indexed user, uint indexed per, uint indexed usdt, uint aienId, uint timestamp);
// 	event BlackUser(address indexed user, bool isBlockUser, uint timestamp, string desc);

// 	modifier isOpenLayer(uint _layer) {
// 		require(layers[_layer].isOpen, 'layer is not open');
// 		_;
// 	}
// 	modifier isBlackUser() {
// 		require(users[msg.sender].isBlockUser != true, 'black user');
// 		_;
// 	}
// 	modifier isP2StopCheck() {
// 		require(isP2Stop != true, 'p2 is stop');
// 		_;
// 	}
// 	modifier isMaxStakingLimit() {
// 		require(users[msg.sender].tokenIds.length() < MAX_STAKING_LIMIT, 'max staking limit');
// 		_;
// 	}
// 	modifier isBlackUser_diamond(address _sender) {
// 		require(users[_sender].isBlockUser != true, 'black user');
// 		_;
// 	}

// 	modifier isMaxStakingLimit_diamond(address _sender) {
// 		require(users[_sender].tokenIds.length() < MAX_STAKING_LIMIT, 'max staking limit');
// 		_;
// 	}
// 	address diamondAddress;

// 	/// @custom:oz-upgrades-unsafe-allow constructor
// 	function initialize() public initializer {
// 		__AccessControl_init();
// 		__UUPSUpgradeable_init();
// 		__ReentrancyGuard_init();

// 		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
// 	}

// 	function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

// 	// 스텝 1
// 	// 첫 셋팅시
// 	// ContractPER = IDB(DB).getContractAddr('PER');
// 	// 이러한 방법으로 셋팅 용이하게 작성했으나, 오히려 가스피는 늘어남.. 그래서 삭제
// 	// ** 실행시 interface를 통해 다른 컨트랙트에 호출할때만 가스피가 늘어나는게 아닌
// 	// ** 배포시에도 byte 변환할때 배포 가스피도 늘어나는 듯
// 	function _P2_Start(
// 		address _dbAddr,
// 		address _perAddr,
// 		address _usdtAddr,
// 		address _aienAddr,
// 		uint _usdt,
// 		uint _per,
// 		uint _p2_dailyReward_Percent,
// 		uint _maxStake
// 	) public onlyRole(DEFAULT_ADMIN_ROLE) {
// 		ContractDB = _dbAddr;
// 		ContractPER = _perAddr;
// 		ContractUSDT = _usdtAddr;
// 		ContractAien = _aienAddr;

// 		MAX_STAKING_LIMIT = _maxStake;

// 		// 기존 IERC20(address).balanceOf(address)를 사용하면 가스피가 늘어나는 문제가 있어서
// 		// 실제로 P2컨트랙트로 전송하고
// 		// 직접 변수에 초기셋팅 기입/ 실제 밸런스와 맞추어 기입 해야함
// 		P2_usdtBalance = _usdt;
// 		P2_perBalance = _per;

// 		P2_dailyReward_Percent = _p2_dailyReward_Percent;

// 		// 스타트할때 초기 값은 하루전으로 셋팅
// 		// 그래야 start하고 레이어 분배 시작
// 		P2_dailyRewardUpdateBlock = block.number - DAY_TO_SEC;
// 		P2_lastRewardBlock = block.number - DAY_TO_SEC;
// 	}

// 	function _layer_setting(
// 		uint _layerNumber,
// 		uint _fromP2PerPercent,
// 		uint _fromP2UsdtPercent,
// 		uint _dailyReward_percent,
// 		uint _add_dailyReward_Percent,
// 		bool _isOpen
// 	) public onlyRole(DEFAULT_ADMIN_ROLE) {
// 		layers[_layerNumber].rewardUsdtPercent = _fromP2UsdtPercent;
// 		layers[_layerNumber].rewardPerPercent = _fromP2PerPercent;
// 		layers[_layerNumber].dailyReward_Percent = _dailyReward_percent;
// 		// 추가됨 Layer struct 참고
// 		layers[_layerNumber].add_dailyReward_Percent = _add_dailyReward_Percent;
// 		layers[_layerNumber].isOpen = _isOpen;
// 	}

// 	function _layer_reset(uint _layerNumber) internal {
// 		layers[_layerNumber].dailyRewardUpdateBlock = block.number;
// 		layers[_layerNumber].lastRewardBlock = block.number;

// 		layers[_layerNumber].balances.savedUsdtBalance += layers[_layerNumber].balances.usdtBalance;
// 		layers[_layerNumber].balances.savedPerBalance += layers[_layerNumber].balances.perBalance;
// 		// console.log(layers[_layerNumber].balances.savedPerBalance);

// 		(uint dailyUSDT, uint dailyPER) = _daily_calc(P2_usdtBalance, P2_perBalance, P2_dailyReward_Percent);
// 		(uint add_dailyUSDT, uint add_dailyPER) = _daily_calc(
// 			layers[_layerNumber].balances.savedUsdtBalance,
// 			layers[_layerNumber].balances.savedPerBalance,
// 			layers[_layerNumber].add_dailyReward_Percent
// 		);

// 		layers[_layerNumber].balances.savedPerBalance -= add_dailyPER;
// 		layers[_layerNumber].balances.savedUsdtBalance -= add_dailyUSDT;

// 		// 문제점  =  (dailyPER / REWARD_PERCENT_DECIMAL * layers[_layerNumber].rewardPerPercent) + add_dailyPER; 으로 수정해야될듯
// 		layers[_layerNumber].balances.perBalance =
// 			((dailyPER / REWARD_PERCENT_DECIMAL) * layers[_layerNumber].rewardPerPercent) +
// 			add_dailyPER;
// 		layers[_layerNumber].balances.usdtBalance =
// 			((dailyUSDT / REWARD_PERCENT_DECIMAL) * layers[_layerNumber].rewardUsdtPercent) +
// 			add_dailyUSDT;
// 		//
// 		layers[_layerNumber].balances.total_checkWithdrawPER = layers[_layerNumber].balances.perBalance;
// 		layers[_layerNumber].balances.total_checkWithdrawUSDT = layers[_layerNumber].balances.usdtBalance;

// 		// console.log('internal layer start!!!!!!!!!!');
// 		_layer_update(_layerNumber);
// 	}

// 	// 전체 풀에 USDT, PER 추가
// 	function addPerUsdtDistribution(uint _usdt, uint _per) public onlyRole(ADDER_ROLE) {
// 		P2_usdtBalance += _usdt;
// 		P2_perBalance += _per;

// 		_p2_update(0);
// 	}

// 	// high pool(6~10)에 PER 추가
// 	function addHighPoolPerDistribution(uint _per) public onlyRole(ADDER_ROLE) {
// 		// layer6~10까지 per 추가
// 		P2_perBalance += _per;

// 		_p2_update(0);
// 	}

// 	function _p2_update(uint _block) internal returns (uint) {
// 		if (P2_dailyRewardUpdateBlock == block.number) return block.number;
// 		if (_block == 0) _block = block.number;
// 		// 만약 P2에서 하위 레이어로 분배하는게 하루가 지났다면
// 		if (_block > P2_dailyRewardUpdateBlock + DAY_TO_SEC) {
// 			// 하루 단위로 레이어로 재원 분배 실행

// 			// from: P2, to: layers로 실제 분배한 리워드들
// 			uint distri_per = 0;
// 			uint distri_usdt = 0;

// 			while (_block > P2_dailyRewardUpdateBlock + DAY_TO_SEC) {
// 				DAYS_Count++;
// 				P2_dailyRewardUpdateBlock += DAY_TO_SEC;
// 				// _daily_calc는 데일리 리워드를 뽑는 퓨어함수 (P2, 하위 레이어들이 공통 실행 함수)
// 				(uint dailyUSDT, uint dailyPER) = _daily_calc(P2_usdtBalance, P2_perBalance, P2_dailyReward_Percent);

// 				for (uint8 i = 1; i < 11; i++) {
// 					(uint add_dailyUSDT, uint add_dailyPER) = _daily_calc(
// 						layers[i].balances.savedUsdtBalance,
// 						layers[i].balances.savedPerBalance,
// 						layers[i].add_dailyReward_Percent
// 					);

// 					distri_per += (dailyPER / REWARD_PERCENT_DECIMAL) * layers[i].rewardPerPercent;
// 					distri_usdt += (dailyUSDT / REWARD_PERCENT_DECIMAL) * layers[i].rewardUsdtPercent;

// 					if (!layers[i].isOpen) {
// 						layers[i].balances.perBalance = 0;
// 						layers[i].balances.usdtBalance = 0;
// 						layers[i].balances.savedPerBalance += ((dailyPER / REWARD_PERCENT_DECIMAL) *
// 							layers[i].rewardPerPercent);
// 						layers[i].balances.usdtBalance += ((dailyUSDT / REWARD_PERCENT_DECIMAL) *
// 							layers[i].rewardUsdtPercent);

// 						continue;
// 					}

// 					layers[i].balances.total_checkWithdrawUSDT +=
// 						(dailyUSDT / REWARD_PERCENT_DECIMAL) *
// 						layers[i].rewardUsdtPercent;
// 					layers[i].balances.total_checkWithdrawPER +=
// 						(dailyPER / REWARD_PERCENT_DECIMAL) *
// 						layers[i].rewardPerPercent;

// 					layers[i].balances.savedUsdtBalance -= add_dailyUSDT;
// 					layers[i].balances.savedPerBalance -= add_dailyPER;

// 					// 문제점
// 					layers[i].balances.perBalance =
// 						((dailyPER / REWARD_PERCENT_DECIMAL) * layers[i].rewardPerPercent) +
// 						add_dailyPER;
// 					layers[i].balances.usdtBalance =
// 						((dailyUSDT / REWARD_PERCENT_DECIMAL) * layers[i].rewardUsdtPercent) +
// 						add_dailyUSDT;
// 				}

// 				//분배 되어야할 dailyReward 차감
// 				P2_perBalance -= distri_per;
// 				P2_usdtBalance -= distri_usdt;
// 			}
// 		}
// 		return block.number;
// 	}

// 	// 오픈 레이어의 가정
// 	function _layer_update(uint _layer) public isOpenLayer(_layer) returns (uint) {
// 		Layer storage layer = layers[_layer];
// 		uint accRewardUsdt = 0;
// 		uint accRewardPer = 0;
// 		// console.log(layer.balances.usdtBalance);
// 		// console.log('layerDailyReward UpdateBlock', layer.dailyRewardUpdateBlock);
// 		if (layer.lastRewardBlock == block.number) return block.number;
// 		if (layer.totalStakedAien == 0) return block.number;

// 		if (block.number > layer.dailyRewardUpdateBlock + DAY_TO_SEC) {
// 			while (block.number > layer.dailyRewardUpdateBlock + DAY_TO_SEC) {
// 				layer.dailyRewardUpdateBlock += DAY_TO_SEC;

// 				accRewardUsdt = ((layer.dailyRewardUpdateBlock - layer.lastRewardBlock) *
// 					(layer.balances.usdtBalance / DAY_TO_SEC) *
// 					((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 				// accRewardUsdt = ((block)*(BlockPerReward)*(데일리리워드 퍼센트));

// 				// /
// 				// 100
// 				// acc = 남은블록의 리워드 * 데일리 리워드 퍼센트
// 				layer.rewardUsdt += accRewardUsdt / layer.totalStakedAien;
// 				// layer.balances.usdtBalance -= accRewardUsdt / PRECISION_FACTOR;
// 				layer.balances.withdrawal_checkWithdrawUSDT += accRewardUsdt / PRECISION_FACTOR;

// 				accRewardPer = ((layer.dailyRewardUpdateBlock - layer.lastRewardBlock) *
// 					(layer.balances.perBalance / DAY_TO_SEC) *
// 					((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 				// /
// 				// 100

// 				layer.rewardPer += accRewardPer / layer.totalStakedAien;
// 				// layer.balances.perBalance -= accRewardPer / PRECISION_FACTOR;
// 				layer.balances.withdrawal_checkWithdrawPER += accRewardPer / PRECISION_FACTOR;

// 				layer.lastRewardBlock = layer.dailyRewardUpdateBlock;
// 			}
// 		}

// 		accRewardUsdt = ((block.number - layer.lastRewardBlock) *
// 			(layer.balances.usdtBalance / DAY_TO_SEC) *
// 			((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 		// /
// 		// 100

// 		layer.rewardUsdt += accRewardUsdt / layer.totalStakedAien;
// 		// layer.balances.usdtBalance -= accRewardUsdt / PRECISION_FACTOR;
// 		layer.balances.withdrawal_checkWithdrawUSDT += accRewardUsdt / PRECISION_FACTOR;

// 		accRewardPer = ((block.number - layer.lastRewardBlock) *
// 			(layer.balances.perBalance / DAY_TO_SEC) *
// 			((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 		// /
// 		// 100

// 		layer.rewardPer += accRewardPer / layer.totalStakedAien;
// 		// layer.balances.perBalance -= accRewardPer / PRECISION_FACTOR;
// 		layer.balances.withdrawal_checkWithdrawPER += accRewardPer / PRECISION_FACTOR;

// 		layer.lastRewardBlock = block.number;

// 		return block.number;
// 	}

	

// 	function pendingReward(uint _aienId, uint _layerNumber, uint _withdrawBlock) public view returns (uint, uint) {
// 		Layer memory layer = layers[_layerNumber];
// 		Aien memory aien = aiens[_aienId];
// 		if (layer.totalStakedAien == 0) return (0, 0);

// 		uint _dailyRewardUpdateBlock = layer.dailyRewardUpdateBlock;
// 		uint _lastRewardBlock = layer.lastRewardBlock;
// 		uint _rewardUSDT = layer.rewardUsdt;
// 		uint _rewardPER = layer.rewardPer;
// 		uint _REWARD_USDT_SUPPLY = layer.balances.usdtBalance;
// 		uint _REWARD_PER_SUPPLY = layer.balances.perBalance;
// 		uint accRewardUsdt = 0;
// 		uint accRewardPer = 0;
// 		uint _nowBlock = _withdrawBlock;

// 		if (_nowBlock == 0) {
// 			_nowBlock = block.number;
// 		}

// 		if (_nowBlock > layer.dailyRewardUpdateBlock + DAY_TO_SEC) {
// 			while (_nowBlock > _dailyRewardUpdateBlock + DAY_TO_SEC) {
// 				// uint add_dailyUSDT;
// 				// uint add_dailyPER;
// 				_dailyRewardUpdateBlock += DAY_TO_SEC;

// 				accRewardUsdt = ((_dailyRewardUpdateBlock - _lastRewardBlock) *
// 					(_REWARD_USDT_SUPPLY / DAY_TO_SEC) *
// 					((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 				// /
// 				// 100

// 				_rewardUSDT += accRewardUsdt / layer.totalStakedAien;
// 				// _REWARD_USDT_SUPPLY -= accRewardUsdt / PRECISION_FACTOR;
// 				_REWARD_USDT_SUPPLY = accRewardUsdt / PRECISION_FACTOR;

// 				accRewardPer = ((_dailyRewardUpdateBlock - _lastRewardBlock) *
// 					(_REWARD_PER_SUPPLY / DAY_TO_SEC) *
// 					((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 				// /
// 				// 100

// 				_rewardPER += accRewardPer / layer.totalStakedAien;
// 				// _REWARD_PER_SUPPLY -= accRewardPer / PRECISION_FACTOR;
// 				_REWARD_PER_SUPPLY = accRewardPer / PRECISION_FACTOR;

// 				_lastRewardBlock = _dailyRewardUpdateBlock;
// 			}
// 		}

// 		accRewardUsdt = ((_nowBlock - _lastRewardBlock) *
// 			(_REWARD_USDT_SUPPLY / DAY_TO_SEC) *
// 			((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 		// /
// 		// 100

// 		_rewardUSDT += accRewardUsdt / layer.totalStakedAien;
// 		// _REWARD_USDT_SUPPLY -= accRewardUsdt / PRECISION_FACTOR;

// 		accRewardPer = ((_nowBlock - _lastRewardBlock) *
// 			(_REWARD_PER_SUPPLY / DAY_TO_SEC) *
// 			((layer.dailyReward_Percent * PRECISION_FACTOR) / REWARD_PERCENT_DECIMAL));
// 		// /
// 		// 100
// 		//
// 		_rewardPER += accRewardPer / layer.totalStakedAien;
// 		// _REWARD_PER_SUPPLY -= accRewardPer / PRECISION_FACTOR;

// 		uint totalRewardPer = _rewardPER - aien.rewardPerDebt;
// 		uint totalRewardUsdt = _rewardUSDT - aien.rewardUsdtDebt;

// 		return (totalRewardPer / PRECISION_FACTOR, totalRewardUsdt / PRECISION_FACTOR);
// 	}

// 	//
// 	//
// 	//
// 	//
// 	//
// 	//
// 	/************ util functions ************/
// 	//ERC721 receiver
// 	function onERC721Received(
// 		address operator,
// 		address from,
// 		uint256 tokenId,
// 		bytes memory data
// 	) public pure returns (bytes4) {
// 		return bytes4(keccak256('onERC721Received(address,address,uint256,bytes)'));
// 	}

// 	// reward transfer
// 	function rewardTransfer(address _to, uint _per, uint _usdt) internal {
// 		IERC20(ContractPER).transfer(_to, _per);
// 		IERC20(ContractUSDT).transfer(_to, _usdt);
// 	}

// 	// aien transfer
// 	function aienTransfer(address _to, uint _id) internal {
// 		IERC721(ContractAien).safeTransferFrom(address(this), _to, _id);
// 	}

// 	// daily calc
// 	function _daily_calc(uint _usdt, uint _per, uint _dailyPercent) internal pure returns (uint, uint) {
// 		uint dailyUSDT = (_usdt * _dailyPercent) / REWARD_PERCENT_DECIMAL;
// 		uint dailyPER = (_per * _dailyPercent) / REWARD_PERCENT_DECIMAL;

// 		return (dailyUSDT, dailyPER);
// 	}

	

// 	// 레이어 넘버를 넣으면 1초당(1블록) 분배 수량과 (24시간 예상 리워드 == returnValue * 86400)
// 	// 레이어에 스테이킹중인 aien 리턴 .
// 	function getLayerData(uint _number) public view returns (uint, uint, uint) {
// 		Layer memory layer = layers[_number];

// 		uint usdt = (layer.balances.savedUsdtBalance * layer.dailyReward_Percent) /
// 			REWARD_PERCENT_DECIMAL /
// 			(layer.totalStakedAien + 1);
// 		uint per = (layer.balances.savedPerBalance * layer.dailyReward_Percent) /
// 			REWARD_PERCENT_DECIMAL /
// 			(layer.totalStakedAien + 1);

// 		// 레이어 넘버를 넣으면 1초당 분배되는 usdt, per 를 리턴 하고
// 		// 레이어에 스테이킹중인 aien 수량 리턴
// 		return (usdt / DAY_TO_SEC, per / DAY_TO_SEC, layer.totalStakedAien);
// 	}

// 	/********** Admin Functions ************/
// 	function __layer_start(uint _layerNumber) external onlyRole(DEFAULT_ADMIN_ROLE) {
// 		_layer_reset(_layerNumber);
// 	}

// 	/********** diamond Functions ************/

// 	function diamond_P2_deposit(
// 		address _sender,
// 		uint _aienId
// 	) external isMaxStakingLimit_diamond(_sender) isBlackUser_diamond(_sender) isP2StopCheck returns (uint) {
// 		require(msg.sender == diamondAddress, 'you are not diamond contract');
// 		require(IERC721(ContractAien).ownerOf(_aienId) == address(_sender), 'not owner');
// 		uint _layer = IDB(ContractDB).getAienLevel(_aienId);
// 		require(_layer != 0, 'not exist');
// 		require(layers[_layer].isOpen, 'layer is not open');

// 		// IERC721(ContractAien).safeTransferFrom(msg.sender, address(this), _aienId);

// 		if (layers[_layer].totalStakedAien == 0) {
// 			_layer_reset(_layer);
// 		}

// 		_p2_update(0);
// 		_layer_update(_layer);

// 		User storage user = users[_sender];

// 		user.tokenIds.add(_aienId);

// 		aiens[_aienId].staker = _sender;
// 		aiens[_aienId].level = _layer;

// 		layers[_layer].totalStakedAien += 1;
// 		//
// 		aiens[_aienId].rewardPerDebt = layers[_layer].rewardPer;
// 		aiens[_aienId].rewardUsdtDebt = layers[_layer].rewardUsdt;

// 		//emit events deposit
// 		emit Deposit(_sender, _aienId, _layer, block.timestamp);

// 		return block.number;
// 	}

// 	function diamond_P2_withdraw(
// 		address _sender,
// 		uint _aienId
// 	) external isBlackUser_diamond(_sender) isP2StopCheck returns (uint) {
// 		require(msg.sender == diamondAddress, 'you are not diamond contract');
// 		Aien storage aien = aiens[_aienId];
// 		User storage user = users[aien.staker];
// 		require(aien.staker == _sender || hasRole(DEFAULT_ADMIN_ROLE, _sender), 'not owner');
// 		uint pendingPER;
// 		uint pendingUSDT;

// 		_p2_update(0);
// 		_layer_update(aien.level);

// 		(pendingPER, pendingUSDT) = pendingReward(_aienId, aien.level, 0);

// 		rewardTransfer(aien.staker, pendingPER, pendingUSDT);

// 		// 출금 총액
// 		user.perRewarded += pendingPER;
// 		user.usdtRewarded += pendingUSDT;
// 		// 7/20
// 		aien.per_received += pendingPER;
// 		aien.usdt_received += pendingUSDT;

// 		user.tokenIds.remove(_aienId);
// 		layers[aien.level].totalStakedAien -= 1;

// 		// 출금시 레이어에 스테이킹된 aien이 없다면 레이어 초기화
// 		if (layers[aien.level].totalStakedAien == 0) {
// 			// console.log('this layer is empty');
// 			layers[aien.level].dailyRewardUpdateBlock = 0;
// 			layers[aien.level].lastRewardBlock = 0;
// 			layers[aien.level].balances.add_dailyPER = 0;
// 			layers[aien.level].balances.add_dailyUSDT = 0;
// 			layers[aien.level].rewardPer = 0;
// 			layers[aien.level].rewardUsdt = 0;
// 		}
// 		aien.rewardPer += pendingPER;
// 		aien.rewardUsdt += pendingUSDT;
// 		aien.rewardPerDebt = layers[aien.level].rewardPer;
// 		aien.rewardUsdtDebt = layers[aien.level].rewardUsdt;

// 		aienTransfer(aien.staker, _aienId);
// 		//emit event withdraw
// 		emit Withdraw(aien.staker, _aienId, aien.level, block.timestamp);

// 		aien.staker = address(0);

// 		return block.number;
// 	}

// 	function diamond_P2_harvest(
// 		address _sender,
// 		uint _aienId
// 	) external isBlackUser_diamond(_sender) isP2StopCheck returns (uint) {
// 		require(msg.sender == diamondAddress, 'you are not diamond contract');
// 		Aien storage aien = aiens[_aienId];
// 		User storage user = users[aien.staker];
// 		require(aien.staker == _sender || hasRole(DEFAULT_ADMIN_ROLE, _sender), 'not owner');

// 		uint pendingPER;
// 		uint pendingUSDT;

// 		_p2_update(0);
// 		_layer_update(aien.level);

// 		(pendingPER, pendingUSDT) = pendingReward(_aienId, aien.level, 0);

// 		rewardTransfer(aien.staker, pendingPER, pendingUSDT);

// 		user.perRewarded += pendingPER;
// 		user.usdtRewarded += pendingUSDT;

// 		aien.rewardPerDebt = layers[aien.level].rewardPer;
// 		aien.rewardUsdtDebt = layers[aien.level].rewardUsdt;

// 		aien.rewardPer += pendingPER;
// 		aien.rewardUsdt += pendingUSDT;
// 		aien.per_received += pendingPER;
// 		aien.usdt_received += pendingUSDT;

// 		//emit event harvest
// 		emit Harvest(aien.staker, pendingPER, pendingUSDT, _aienId, block.timestamp);
// 		return block.number;
// 	}

// 	function diamond_P2_getUserInfo(
// 		address _sender
// 	) public view returns (UserLoadData memory, AienLoadData[] memory, LayerLoadData[] memory) {
// 		User storage user = users[_sender];
// 		UserLoadData memory _UserLoadData = UserLoadData(
// 			users[_sender].perRewarded,
// 			users[_sender].usdtRewarded,
// 			users[_sender].isBlockUser
// 		);

// 		// PageLoad memory pageLoad;

// 		AienLoadData[] memory _AienLoadData = new AienLoadData[](user.tokenIds.length());
// 		LayerLoadData[] memory _LayerLoadData = new LayerLoadData[](11);

// 		for (uint i = 0; i < user.tokenIds.length(); i++) {
// 			(uint _per, uint _usdt) = pendingReward(user.tokenIds.at(i), aiens[user.tokenIds.at(i)].level, 0);

// 			_AienLoadData[i]._aienId = user.tokenIds.at(i);
// 			_AienLoadData[i]._aienLevel = aiens[user.tokenIds.at(i)].level;
// 			_AienLoadData[i]._aien_per_received = aiens[user.tokenIds.at(i)].per_received;
// 			_AienLoadData[i]._aien_usdt_received = aiens[user.tokenIds.at(i)].usdt_received;
// 			_AienLoadData[i].block_reward_per =
// 				((layers[aiens[user.tokenIds.at(i)].level].balances.perBalance *
// 					layers[aiens[user.tokenIds.at(i)].level].dailyReward_Percent) /
// 					REWARD_PERCENT_DECIMAL /
// 					layers[aiens[user.tokenIds.at(i)].level].totalStakedAien) /
// 				DAY_TO_SEC;

// 			_AienLoadData[i].block_reward_usdt =
// 				((layers[aiens[user.tokenIds.at(i)].level].balances.usdtBalance *
// 					layers[aiens[user.tokenIds.at(i)].level].dailyReward_Percent) /
// 					REWARD_PERCENT_DECIMAL /
// 					layers[aiens[user.tokenIds.at(i)].level].totalStakedAien) /
// 				DAY_TO_SEC;
// 			_AienLoadData[i].usdt_withdrawable = _usdt;
// 			_AienLoadData[i].per_withdrawable = _per;
// 		}

// 		for (uint i = 1; i < 11; i++) {
// 			Layer memory layer = layers[i];
// 			// if(layer.isOpen == false) break;
// 			(uint dailyUSDT, uint dailyPER) = _daily_calc(P2_usdtBalance, P2_perBalance, P2_dailyReward_Percent);

// 			(uint add_dailyUSDT, uint add_dailyPER) = _daily_calc(
// 				layer.balances.savedUsdtBalance,
// 				layer.balances.savedPerBalance,
// 				layer.add_dailyReward_Percent
// 			);
// 			uint _totalStakedAien;
// 			layer.totalStakedAien == 0 ? _totalStakedAien = 1 : _totalStakedAien = layer.totalStakedAien;
// 			_LayerLoadData[i]._layerNumber = i;
// 			_LayerLoadData[i].isOpen = layer.isOpen;
// 			_LayerLoadData[i]._24h_reward_usdt =
// 				(((((P2_usdtBalance * P2_dailyReward_Percent) / REWARD_PERCENT_DECIMAL) * layers[i].rewardUsdtPercent) /
// 					REWARD_PERCENT_DECIMAL) + add_dailyUSDT) /
// 				_totalStakedAien;

// 			_LayerLoadData[i]._24h_reward_per =
// 				(((((P2_perBalance * P2_dailyReward_Percent) / REWARD_PERCENT_DECIMAL) * layers[i].rewardPerPercent) /
// 					REWARD_PERCENT_DECIMAL) + add_dailyPER) /
// 				_totalStakedAien;

// 			_LayerLoadData[i].totalStakedAien = layer.totalStakedAien;
// 		}

// 		return (_UserLoadData, _AienLoadData, _LayerLoadData);
// 	}

// 	function diamond_P2_getLayerData(uint _number) external view returns (uint, uint, uint) {
// 		Layer memory layer = layers[_number];

// 		uint usdt = (layer.balances.savedUsdtBalance * layer.dailyReward_Percent) /
// 			REWARD_PERCENT_DECIMAL /
// 			(layer.totalStakedAien + 1);
// 		uint per = (layer.balances.savedPerBalance * layer.dailyReward_Percent) /
// 			REWARD_PERCENT_DECIMAL /
// 			(layer.totalStakedAien + 1);

// 		// 레이어 넘버를 넣으면 1초당 분배되는 usdt, per 를 리턴 하고
// 		// 레이어에 스테이킹중인 aien 수량 리턴
// 		return (usdt / DAY_TO_SEC, per / DAY_TO_SEC, layer.totalStakedAien);
// 	}

// 	// diamond admin function call
// 	function setDiamondAddress(address _diamond) external onlyRole(DEFAULT_ADMIN_ROLE) {
// 		diamondAddress = _diamond;
// 	}

// 	function diamond_P2_BlockUser(address _address, bool _block, string memory _why) external {
// 		// 유저 블락
// 		require(msg.sender == diamondAddress, 'you are not diamond contract');
// 		users[_address].isBlockUser = _block;
// 		emit BlackUser(_address, _block, block.timestamp, _why);
// 	}

// 	function diamond_P2_setMaxLimit(uint _MAX_STAKING_LIMIT) external {
// 		require(msg.sender == diamondAddress, 'you are not diamond contract');
// 		MAX_STAKING_LIMIT = _MAX_STAKING_LIMIT;
// 	}

// 	function setPerP2Balance(uint _per, uint _usdt) external onlyRole(DEFAULT_ADMIN_ROLE) {
// 		// per 잔고 설정
// 		P2_perBalance = _per;
// 		P2_usdtBalance = _usdt;
// 	}

// 	function exitAien(address _tokenaddr, uint _id, address _to) external onlyRole(DEFAULT_ADMIN_ROLE) {
// 		// aien 출금

// 		IERC721(_tokenaddr).safeTransferFrom(address(this), _to, _id);
// 	}

// 	function setOusdt(address _ousdt) external onlyRole(DEFAULT_ADMIN_ROLE) {
// 		// ousdt 설정
// 		ContractUSDT = _ousdt;
// 	}

// 	function p2DailyRewardPercent(uint _percent) external onlyRole(DEFAULT_ADMIN_ROLE) {
// 		// p2 데일리 리워드 퍼센트 설정
// 		P2_dailyReward_Percent = _percent;
// 	}
// }
