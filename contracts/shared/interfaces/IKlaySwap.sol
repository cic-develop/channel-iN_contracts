// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 0xc6a2ad8cc6e4a7e08fc37cc5954be07d499e7654 KSP
// 0x7A74B3be679E194E1D6A0C29A343ef8D2a5AC876 Util
interface IKlaySwap {
    function estimateSwap(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        address[] memory path
    ) external view returns (uint amountOut);

    function exchangeKctPos(
        address tokenA,
        uint amountA,
        address tokenB,
        uint amountB,
        address[] memory path
    ) external;
}




