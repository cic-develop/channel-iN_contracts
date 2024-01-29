// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IMarket {
    // admin
    function setMarketFee(uint256 _marketFee) external;

    function createCollection(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) external;

    function pauseCollection(uint256 _collectionId) external;

    // strcut
    // 1. MarketPlace
    // 2. Collection
    // 3. Item
    // 4. Order

    // call Front
    // other project external call
}
