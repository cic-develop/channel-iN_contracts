// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

// contract DbStorage {
//     uint256 public latestPfId;
// }
// // import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
// // import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
// // import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
// // import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
// // // interfaces
// // import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
// // import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
// // import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

// // interface IFACTORY {
// // 	function mint(address _to, uint _tokenId, string memory _tokenURI) external;
// // }

// // contract DB is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
// // 	bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
// // 	bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');
// // 	bytes32 public constant MINT_ROLE = keccak256('MINT_ROLE');
// // 	bytes32 public constant MIX_ROLE = keccak256('MIX_ROLE');
// // 	bytes32 public constant SUPPORT_ROLE = keccak256('SUPPORT_ROLE');

// // 	// pf
// // 	struct pf {
// // 		uint id;
// // 		uint class;
// // 		bool isAien;
// // 		uint usedAienId;
// // 	}

// // 	struct pfGrade {
// // 		uint normal;
// // 		uint uncommon;
// // 		uint rare;
// // 		uint unique;
// // 		uint legendary;
// // 		uint myth;
// // 		uint ancient;
// // 	}

// // 	struct aien {
// // 		uint id;
// // 		// 강화 횟수
// // 		uint mixCount;
// // 		//
// // 		uint p2Level;
// // 		// 토탈 경험치
// // 		uint totalExp;
// // 		// 미션 및, 인플루언서 활동 관련 경험치
// // 		uint influExp;
// // 		// 기본 확률
// // 		uint baseProb;
// // 		// 토탈 확률
// // 		uint totalProb;
// // 		// is PF
// // 		uint isPFid;
// // 		// 추가확률
// // 		uint addProb;
// // 	}

// // 	struct items {
// // 		uint id;
// // 		address owner;
// // 		// uint useCount;
// // 	}

// // 	// PF 현재 현황
// // 	pfGrade public PfGrades;

// // 	mapping(uint => pf) public PFS;
// // 	mapping(uint => aien) public AIENS;
// // 	mapping(uint => items) public ITEMS;

// // 	/// @custom:oz-upgrades-unsafe-allow constructor
// // 	function initialize() public initializer {
// // 		__Pausable_init();
// // 		__AccessControl_init();
// // 		__UUPSUpgradeable_init();

// // 		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
// // 		_grantRole(PAUSER_ROLE, msg.sender);
// // 		_grantRole(UPGRADER_ROLE, msg.sender);
// // 		_grantRole(MINT_ROLE, msg.sender);
// // 	}

// // 	function pause() public onlyRole(PAUSER_ROLE) {
// // 		_pause();
// // 	}

// // 	function unpause() public onlyRole(PAUSER_ROLE) {
// // 		_unpause();
// // 	}

// // 	function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

// // 	////////////////////////////////custom functions//////////////////////////////////////

// // 	////////////////////////////////internal functions//////////////////////////////////////

// // 	//set Aien
// // 	function _setAien(uint _id) internal returns (bool) {
// // 		AIENS[_id].id = _id;
// // 		aienGrades[0].aienLevelCount++;
// // 		return true;
// // 	}

// // 	//set PfGrades
// // 	function _setGrades(uint _grade) internal returns (bool) {
// // 		if (_grade == 1) {
// // 			PfGrades.normal += 1;
// // 		} else if (_grade == 2) {
// // 			PfGrades.uncommon += 1;
// // 		} else if (_grade == 3) {
// // 			PfGrades.rare += 1;
// // 		} else if (_grade == 4) {
// // 			PfGrades.unique += 1;
// // 		} else if (_grade == 5) {
// // 			PfGrades.legendary += 1;
// // 		} else if (_grade == 6) {
// // 			PfGrades.myth += 1;
// // 		} else if (_grade == 7) {
// // 			PfGrades.ancient += 1;
// // 		}

// // 		return true;
// // 	}

// // 	////////////////////////////////internal functions//////////////////////////////////////

// // 	////////////////////////////////external functions//////////////////////////////////////

// // 	function setPF(uint _id, uint _class) public onlyRole(MINT_ROLE) {
// // 		PFS[_id].id = _id;
// // 		PFS[_id].class = _class;

// // 		_setGrades(_class);
// // 	}

// // 	function setAien(uint _id) external onlyRole(MINT_ROLE) {
// // 		_setAien(_id);
// // 	}

// // 	function getPF(uint _id) external view returns (pf memory) {
// // 		return PFS[_id];
// // 	}

// // 	function getPfGrade(uint _id) external view returns (uint) {
// // 		return PFS[_id].class;
// // 	}

// // 	function getAien(uint _id) external view returns (aien memory) {
// // 		return AIENS[_id];
// // 	}

// // 	function getGradeStatus() public view returns (pfGrade memory) {
// // 		return PfGrades;
// // 	}

// // 	////////////////////////////////external functions//////////////////////////////////////

// // 	// admin function
// // 	function setPFGradeStatus(
// // 		uint _normal,
// // 		uint _uncommon,
// // 		uint _rare,
// // 		uint _unique,
// // 		uint _legendary,
// // 		uint _myth,
// // 		uint _ancient
// // 	) public onlyRole(DEFAULT_ADMIN_ROLE) {
// // 		PfGrades.normal = _normal;
// // 		PfGrades.uncommon = _uncommon;
// // 		PfGrades.rare = _rare;
// // 		PfGrades.unique = _unique;
// // 		PfGrades.legendary = _legendary;
// // 		PfGrades.myth = _myth;
// // 		PfGrades.ancient = _ancient;
// // 	}

// // 	function usePFimg(uint _aienId, uint _pfId) external onlyRole(MINT_ROLE) {
// // 		PFS[_pfId].usedAienId = _aienId;
// // 		AIENS[_aienId].isPFid = _pfId;
// // 	}

// // 	// all set aien
// // 	function setAienAll(
// // 		uint _id,
// // 		uint _mixCount,
// // 		uint _p2Level,
// // 		uint _totalExp,
// // 		uint _influExp,
// // 		uint _baseProb,
// // 		uint _totalProb,
// // 		uint _isPFid,
// // 		uint _addProb
// // 	) external onlyRole(MINT_ROLE) {
// // 		AIENS[_id].id = _id;
// // 		AIENS[_id].mixCount = _mixCount;
// // 		AIENS[_id].p2Level = _p2Level;
// // 		AIENS[_id].totalExp = _totalExp;
// // 		AIENS[_id].influExp = _influExp;
// // 		AIENS[_id].baseProb = _baseProb;
// // 		AIENS[_id].totalProb = _totalProb;
// // 		AIENS[_id].isPFid = _isPFid;
// // 		AIENS[_id].addProb = _addProb;
// // 	}

// // 	// all set pf
// // 	function setPfAll(uint _id, uint _class, bool _isAien, uint _usedAienId) external onlyRole(MINT_ROLE) {
// // 		PFS[_id].id = _id;
// // 		PFS[_id].class = _class;
// // 		PFS[_id].isAien = _isAien;
// // 		PFS[_id].usedAienId = _usedAienId;
// // 	}

// // 	struct assetContract {
// // 		address addr;
// // 	}
// // 	struct BurnState {
// // 		// 총 밸런스
// // 		uint perTotalSupply;
// // 		// 유통량
// // 		uint perDistributed;
// // 		// 소각량
// // 		uint perBurnValues;
// // 	}

// // 	mapping(string => address) public assetContracts;
// // 	BurnState public burnToken;
// // 	string[] public contractNames;

// // 	function getContractAddr(string memory _name) public view returns (address) {
// // 		return assetContracts[_name];
// // 	}

// // 	function setContractAddr(string memory _name, address _addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
// // 		if (assetContracts[_name] == address(0x0)) {
// // 			contractNames.push(_name);
// // 		}
// // 		assetContracts[_name] = _addr;
// // 	}

// // 	function getContractNames() public view returns (string[] memory) {
// // 		return contractNames;
// // 	}

// // 	function setBurnState(uint _totalSupply, uint _perDist, uint _burnAmount) public onlyRole(DEFAULT_ADMIN_ROLE) {
// // 		burnToken.perTotalSupply = _totalSupply;
// // 		burnToken.perDistributed = _perDist;
// // 		burnToken.perBurnValues = _burnAmount;
// // 	}

// // 	function burnValue(uint _burnAmount) public onlyRole(MINT_ROLE) {
// // 		burnToken.perBurnValues += _burnAmount;
// // 	}

// // 	function getAienLevel(uint _aienId) public view returns (uint) {
// // 		return AIENS[_aienId].p2Level;
// // 	}

// // 	struct AienGrade {
// // 		uint aienLevelCount;
// // 	}

// // 	mapping(uint => AienGrade) public aienGrades;

// // 	function setAienGradeInfo(uint _toGrade) public onlyRole(MINT_ROLE) {
// // 		aienGrades[_toGrade].aienLevelCount++;
// // 		aienGrades[_toGrade - 1].aienLevelCount--;
// // 	}

// // 	function getAienGradeInfo() public view returns (uint[] memory) {
// // 		uint[] memory _grades = new uint[](11);

// // 		for (uint i = 0; i < 11; i++) {
// // 			_grades[i] = aienGrades[i].aienLevelCount;
// // 		}
// // 		return _grades;
// // 	}

// // 	function setAienGrades(uint _grade, uint _count) public onlyRole(MINT_ROLE) {
// // 		aienGrades[_grade].aienLevelCount = _count;
// // 	}

// // 	fallback() external payable {}

// // 	receive() external payable {}

// // 	// 7/19일 추가 function

// // 	function subPfGrades(uint _pfId) public onlyRole(MINT_ROLE) {
// // 		_subPfGrades(PFS[_pfId].class);
// // 	}

// // 	function _subPfGrades(uint _grade) internal returns (bool) {
// // 		if (_grade == 1) {
// // 			PfGrades.normal -= 1;
// // 		} else if (_grade == 2) {
// // 			PfGrades.uncommon -= 1;
// // 		} else if (_grade == 3) {
// // 			PfGrades.rare -= 1;
// // 		} else if (_grade == 4) {
// // 			PfGrades.unique -= 1;
// // 		} else if (_grade == 5) {
// // 			PfGrades.legendary -= 1;
// // 		} else if (_grade == 6) {
// // 			PfGrades.myth -= 1;
// // 		} else if (_grade == 7) {
// // 			PfGrades.ancient -= 1;
// // 		}

// // 		return true;
// // 	}

// // 	function _failedAienSet(
// // 		uint _id,
// // 		uint _totalExp,
// // 		uint _influExp,
// // 		uint _baseProb,
// // 		uint _addProb
// // 	) external onlyRole(MINT_ROLE) {
// // 		AIENS[_id].id = _id;
// // 		AIENS[_id].mixCount++;
// // 		AIENS[_id].totalExp = _totalExp;
// // 		AIENS[_id].influExp = _influExp;
// // 		AIENS[_id].baseProb = _baseProb;
// // 		AIENS[_id].addProb = _addProb;
// // 	}

// // 	function _successAienSet(
// // 		uint _id,
// // 		uint _p2Level,
// // 		uint _totalExp,
// // 		uint _influExp,
// // 		uint _baseProb,
// // 		uint _addProb
// // 	) external onlyRole(MINT_ROLE) {
// // 		AIENS[_id].id = _id;
// // 		AIENS[_id].mixCount++;
// // 		AIENS[_id].p2Level = _p2Level;
// // 		AIENS[_id].totalExp = _totalExp;
// // 		AIENS[_id].influExp = _influExp;
// // 		AIENS[_id].baseProb = _baseProb;
// // 		AIENS[_id].addProb = _addProb;

// // 		aienGrades[_p2Level].aienLevelCount++;
// // 		aienGrades[_p2Level - 1].aienLevelCount == 0
// // 			? aienGrades[_p2Level - 1].aienLevelCount
// // 			: aienGrades[_p2Level - 1].aienLevelCount--;
// // 	}

// // 	function usePFPower(uint _aienId, uint _usePower) external onlyRole(MINT_ROLE) {
// // 		require(AIENS[_aienId].addProb >= _usePower, 'not enugh power');
// // 		AIENS[_aienId].addProb -= _usePower;
// // 	}
// // }

// // contract DBV2 is DB {
// // 	struct User {
// // 		// DB > idx
// // 		uint userId;
// // 		// token itme ID
// // 		uint itemId;
// // 		address incomeAddr;
// // 		uint feeBalance;
// // 		bool isAble;
// // 		uint mintCount;
// // 		uint useLevelupCount;
// // 		uint useMergeCount;
// // 		uint ownerIncomePercent;
// // 		uint userIncomPercent;
// // 		//레퍼럴로 얻은 수익
// // 		uint referralIncome;
// // 	}

// // 	uint maxIncomePercent;

// // 	uint mintFee;
// // 	uint mergeFee;
// // 	uint levelupFee;

// // 	bool isAble;

// // 	address factory;
// // 	mapping(address => User) public users;
// // 	uint ownerIncomePercent;
// // 	uint userIncomPercent;

// // 	uint public latestPfId;
// // 	uint public chargePfId;
// // 	mapping(uint => string) public pfMetaURI;

// // 	function _adminSetFees(
// // 		uint _mintFee,
// // 		uint _mergeFee,
// // 		uint _levelupFee,
// // 		uint _ownerIncomePercent,
// // 		uint _lastPfId
// // 	) external onlyRole(MINT_ROLE) {
// // 		mintFee = _mintFee;
// // 		mergeFee = _mergeFee;
// // 		levelupFee = _levelupFee;
// // 		latestPfId = _lastPfId;
// // 		ownerIncomePercent = _ownerIncomePercent;
// // 	}

// // 	function _adminSetMaxIncomPercent(uint _maxIncomePercent) external onlyRole(MINT_ROLE) {
// // 		maxIncomePercent = _maxIncomePercent;
// // 	}

// // 	function InfluecnerSetIncome(address _addr, uint _ownerIncomePercent, uint _userIncomPercent) public {
// // 		require(maxIncomePercent >= _ownerIncomePercent + _userIncomPercent, 'over max percent');

// // 		ownerIncomePercent = _ownerIncomePercent;
// // 		userIncomPercent = _userIncomPercent;
// // 	}

// // 	function getInfluencerItem(uint _id) public view returns (address) {
// // 		return ITEMS[_id].owner;
// // 	}

// // 	// 인플루언서가 민트할때 수수료 예치
// // 	// function chargeMintFee() {}

// // 	// 인플루언서 예치수수료 출금
// // 	// function exitMintFee(uint _amount) external {
// // 	//   users[msg.sender].feeBalance -= _amount;
// // 	//   // msg.sender.transfer(_amount);
// // 	// }

// // 	// i-Match에서 mint시 호출
// // 	function influencerMint(uint _amount, uint _itemId, bytes memory _data) external onlyRole(MINT_ROLE) {
// // 		address influencerAddr = bytesToAddress(_data);

// // 		// require(users[influencerAddr].feeBalance >= mintFee, 'not enugh fee');
// // 		require(users[influencerAddr].isAble == isAble, 'not able');

// // 		if (ITEMS[_itemId].owner == address(0) && _itemId > 50) {
// // 			ITEMS[_itemId].owner = influencerAddr;
// // 			users[influencerAddr].userId = _itemId;
// // 			users[influencerAddr].itemId = _itemId;
// // 			users[influencerAddr].incomeAddr = influencerAddr;
// // 		}

// // 		users[influencerAddr].mintCount += _amount;
// // 		// users[influencerAddr].feeBalance -= mintFee;
// // 	}

// // 	// // tez에서 item 병합시 호출
// // 	// // not Use!!!!!!!!
// // 	// function influencerMerge(address _to, uint _itemId) external onlyRole(MINT_ROLE) returns (address) {
// // 	//   // require(users[[ITEMS[_itemId].owner]].isAble == isAble, 'not able');
// // 	//   // users[[ITEMS[_itemId].owner]].useMergeCount++;
// // 	//   // users[[ITEMS[_itemId].owner]].referralIncome++;
// // 	//   // // pf NFT 민트해야됨
// // 	//   // // IFACTORY(factory).mint(_to, latestPfId, 'https://'+latestPfId);
// // 	//   // return ITEMS[_itemId].owner;
// // 	// }

// // 	// myPage에서 나의 item 현황, 정보 호출
// // 	function myItemInfos(address _addr) public view returns (User memory) {
// // 		User memory _user = users[_addr];

// // 		return _user;
// // 	}

// // 	function bytesToAddress(bytes memory b) public pure returns (address) {
// // 		require(b.length == 20, 'Invalid address');
// // 		address addr;
// // 		assembly {
// // 			addr := mload(add(b, 20))
// // 		}
// // 		return addr;
// // 	}

// // 	function setLatestPfId(uint _id) external onlyRole(MINT_ROLE) {
// // 		// 12962
// // 		latestPfId = _id;
// // 	}

// // 	function _influencerMerge(
// // 		address _to,
// // 		uint _itemId,
// // 		uint _referralIncome
// // 	) external onlyRole(MINT_ROLE) returns (address, uint, string memory) {
// // 		address influencerAddr = ITEMS[_itemId].owner;
// // 		require(users[influencerAddr].isAble == isAble, 'not able');
// // 		require(latestPfId <= chargePfId, 'not enugh pf metadata');

// // 		string memory _metaURI = 'https://ipfs.io/ipfs/';
// // 		string memory _pfURI = pfMetaURI[latestPfId];
// // 		uint _latestPfId = latestPfId;

// // 		if (_itemId > 50) {
// // 			users[influencerAddr].useMergeCount++;
// // 			users[influencerAddr].referralIncome += _referralIncome;

// // 			// 정보저장까지 완료 해당 아이디로 PF 민트만 하면 됨
// // 			setPF(latestPfId, 1);
// // 			IFACTORY(factory).mint(_to, latestPfId, string.concat(_metaURI, _pfURI));

// // 			latestPfId++;

// // 			return (influencerAddr, _latestPfId, pfMetaURI[_latestPfId]);
// // 		} else {
// // 			// 정보저장까지 완료 해당 아이디로 PF 민트만 하면 됨
// // 			setPF(latestPfId, 1);
// // 			IFACTORY(factory).mint(_to, latestPfId, string.concat(_metaURI, _pfURI));

// // 			latestPfId++;

// // 			return (address(0x0), _latestPfId, pfMetaURI[_latestPfId]);
// // 		}
// // 	}

// // 	function _incomeCalcul() external view returns (uint, uint) {
// // 		uint _mergeFee = mergeFee;
// // 		uint _ownerIncomePercent = ownerIncomePercent;
// // 		uint _influencerIncomeFee = (_mergeFee * _ownerIncomePercent) / 1e5;
// // 		return (mergeFee, _influencerIncomeFee);
// // 	}

// // 	function _setMetadata(uint _pfId, string memory seedHash) external onlyRole(MINT_ROLE) {
// // 		pfMetaURI[_pfId] = seedHash;
// // 		chargePfId = _pfId;
// // 	}

// // 	function _getMedataMargin() external view returns (uint, uint, uint) {
// // 		return (latestPfId, chargePfId, chargePfId - latestPfId);
// // 	}

// // 	function _setFactoryAddr(address _factoryAddr) external onlyRole(DEFAULT_ADMIN_ROLE) {
// // 		factory = _factoryAddr;
// // 	}

// // 	function _setChargePfId(uint _chargePfId) external onlyRole(DEFAULT_ADMIN_ROLE) {
// // 		chargePfId = _chargePfId;
// // 	}

// // 	// function _influencerLevelUp(
// // 	//   address _to,
// // 	//   uint _itemId,
// // 	//   uint _referralIncome
// // 	// ) external onlyRole(MINT_ROLE) returns (address) {
// // 	//   require(users[[ITEMS[_itemId].owner]].isAble == isAble, 'not able');

// // 	//   users[[ITEMS[_itemId].owner]].useLevelupCount++;
// // 	//   users[[ITEMS[_itemId].owner]].referralIncome += _referralIncome;

// // 	//   return ITEMS[_itemId].owner;
// // 	// }
// // 	// ///////////////////////////////////////////////////////////////////
// // 	// ///////////////////////////////////////////////////////////////////
// // 	// ///////////////////////////////////////////////////////////////////

// // 	// function _normalMerge() external onlyRole(MINT_ROLE) returns (uint) {
// // 	//   latestPfId++;
// // 	//   setPF(latestPfId, 1);

// // 	//   return latestPfId;
// // 	// }
// // }
