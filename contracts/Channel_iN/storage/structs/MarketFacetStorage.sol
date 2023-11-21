// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

struct paymentToken {
    address _tokenAddr;
}

struct ERC721_Exchange {
    address _targetTokenAddr;
    address _owner;
    uint16 _feeRatio;
    bool _isPause;
}

struct ERC1155_Exchange {
    address _targetTokenAddr;
    address _owner;
    uint16 _feeRatio;
    bool _isPause;
}

struct ERC721_OrderBook {
    // 추가 필요
    uint _id;
}

struct ERC1155_OrderBook {
    // 추가 필요
    uint _id;
}

struct MarketFacetStorage {
    // global status
    uint32 exchangeCount;
    uint8 global_feeDecimal;
    uint16 tez_feeRatio;
    //
    bool isPause;
    bool isAdd;
    //
    mapping(address => ERC721_Exchange) ERC721_Exchanges;
    mapping(address => ERC1155_Exchange) ERC1155_Exchanges;
    mapping(address => ERC721_OrderBook) ERC721_OrderBooks;
    mapping(address => ERC1155_OrderBook) ERC1155_OrderBooks;
    //
    // // payment token list
    // address[] paymentTokenList;
}

contract MarketModifier {}
