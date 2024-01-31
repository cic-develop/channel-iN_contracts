// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

library LibMarketPlace {
    
    // events
    event CreateCollection(
        address indexed nftAddress,
        uint8 indexed nftType,
        bool indexed isOpen
    );
    event CreateOrder(
        address indexed nftAddress,
        uint indexed orderId,
        uint8 indexed orderType
    );
    event CancelOrder(
        address indexed nftAddress,
        uint indexed orderId,
        uint8 indexed orderType
    );

    function setOrder(
        address _nftAddress,
        uint8 _orderType,
        uint _tokenId,
        uint _price
    ) internal {}

    function getOrder(address _nftAddress, uint _tokenId) internal {}

    function matchOrder(address _nftAddress, uint _tokenId) internal {}

    function _setFloorPrice(
        address _nftAddress,
        uint _tokenId,
        uint _price
    ) internal {}

    function _matchOrder(
        address _nftAddress,
        uint _tokenId,
        uint _price
    ) internal {}

    function _cancelOrder(address _nftAddress, uint _tokenId) internal {}




}
