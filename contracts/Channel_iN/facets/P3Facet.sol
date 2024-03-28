// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IUniswapV2Router02} from "../interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "../interfaces/IUniswapV2Factory.sol";

// Dex Contract

contract P3Facet {
    AppStorage internal s;

    function P3_getPairLists() external view returns (address[] memory) {
        IUniswapV2Factory factory = IUniswapV2Factory(
            s.contracts["dexv2factory"]
        );
        uint256 length = factory.allPairsLength();
        address[] memory pairs = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            pairs[i] = factory.allPairs(i);
        }
        return pairs;
    }

    function P3_getPairAddress(
        address _tokenA,
        address _tokenB
    ) external view returns (address) {
        IUniswapV2Factory factory = IUniswapV2Factory(
            s.contracts["dexv2factory"]
        );
        return factory.getPair(_tokenA, _tokenB);
    }

    function P3_getQuote(
        address _tokenA,
        address _tokenB,
        uint _amountA
    ) external view returns (uint amountB) {
        IUniswapV2Router02 router = IUniswapV2Router02(
            s.contracts["dexv2router"]
        );
        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;
        amountB = router.getAmountsOut(_amountA, path)[1];
    }

    
}
