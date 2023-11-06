// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

interface IDB {
	function influencerMint(uint _amount, uint _itemId, bytes calldata _data) external;
}

contract channel_in_item_V1 is
	Initializable,
	ERC1155Upgradeable,
	OwnableUpgradeable,
	PausableUpgradeable,
	ERC1155BurnableUpgradeable,
	ERC1155SupplyUpgradeable
{
	mapping(address => bool) public blackList;

	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		_disableInitializers();
	}

	function initialize() public initializer {
		__ERC1155_init('');
		__Ownable_init();
		__Pausable_init();
		__ERC1155Burnable_init();
		__ERC1155Supply_init();
	}

	function setURI(string memory newuri) public onlyOwner {
		_setURI(newuri);
	}

	function pause() public onlyOwner {
		_pause();
	}

	function unpause() public onlyOwner {
		_unpause();
	}

	function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
		_mint(account, id, amount, data);

		// unkwon contract
		// IDB(address(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512)).influencerMint(amount, id, data);

		if (id > 50) {
			// // mainnet contract
			IDB(address(0x0967358cB6a94aCF45A99Fb4ED199C081bbe2121)).influencerMint(amount, id, data);

			// test contract
			// IDB(address(0x4f47CF617Cdd6eA9d1b235Af05650cd0e83B8C62)).influencerMint(amount, id, data);
		}
	}

	function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
		_mintBatch(to, ids, amounts, data);
	}

	function _beforeTokenTransfer(
		address operator,
		address from,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) whenNotPaused {
		require(!blackList[from] && !blackList[operator] && !blackList[to], 'blackList User');
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}

	function _setBlackList(address _user, bool _bool) public onlyOwner {
		blackList[_user] = _bool;
	}
}
