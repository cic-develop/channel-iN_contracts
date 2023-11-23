// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {MarketStorageFacet} from "../../storage/facets/MarketStorageFacet.sol";
// add interfaces 721,1155


contract MarketFacet {
    // oder functions
    function m_721_sell() public {}

    function m_721_buy() public {}

    function m_1155_sell() public {}

    function m_1155_buy() public {}


    // opt functions
    // 1155의 경우 다른형식의 오더북 필요, 예를들어 시장가 구매 > 수량 설정, 금액 설정
    
    
}
