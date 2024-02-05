// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";

library LibP3_721 {
    // events
    event CreateCollection_721(
        address indexed _nftAddr,
        string _name,
        string _symbol
    );

    event BuyOrder_721(
        address indexed _nftAddr,
        address indexed _buyer,
        uint indexed _orderId,
        uint _tokenId,
        uint _price
    );
    event SellOrder_721(
        address indexed _nftAddr,
        address indexed _seller,
        uint indexed _orderId,
        uint _tokenId,
        uint _price
    );

    event CancelOrder_721(
        address indexed _nftAddr,
        address indexed _cancler,
        uint indexed _orderId
    );

    event MatchOrder_721(
        address indexed _nftAddr,
        address indexed _buyer,
        address indexed _seller,
        uint _orderId,
        uint _tokenId,
        uint _price
    );

    function _createCollection_721(address _nftAddr) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            s.p3_721_collections[_nftAddr].isOpen == false,
            "LibP3_721: already created"
        );
        s.p3_721_collections[_nftAddr].name = ERC721(_nftAddr).name();
        s.p3_721_collections[_nftAddr].symbol = ERC721(_nftAddr).symbol();
        s.p3_721_collections[_nftAddr].isOpen = true;

        emit CreateCollection_721(
            _nftAddr,
            s.p3_721_collections[_nftAddr].name,
            s.p3_721_collections[_nftAddr].symbol
        );
    }

    function _buyOrder_721(
        address _sender,
        address _nftAddr,
        uint _tokenId,
        uint _price
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // require()

    }

    function _sellOrder_721(
        address _nftAddr,
        uint _tokenId,
        uint _price
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
    }

    function _matchOrder_721(
        address _nftAddr,
        uint _orderId,
        uint _tokenId,
        uint _price
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
    }

    function _cancelOrder_721(uint _orderId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
    }

    // internal uitl functions
    function __check() internal {}
}
