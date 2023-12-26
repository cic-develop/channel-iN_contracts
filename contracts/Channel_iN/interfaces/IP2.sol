// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IP2 {
    struct Aien {
        address staker;
        uint level;
        // requires value
        uint rewardPer;
        uint rewardUsdt;
        uint rewardUsdtDebt;
        uint rewardPerDebt;
        ////////////////////
        uint per_received;
        uint usdt_received;
    }

    function aiens(uint _id) external view returns (Aien memory);
}
