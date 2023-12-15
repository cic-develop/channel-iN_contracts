// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IAggregator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IAggregator.sol";
import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";

contract PriceFeedFacet {
    function getLatestData(address _proxy) public returns (int256) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        IAggregator dataFeed = IAggregator(_proxy);
        (
            uint80 roundId_,
            int256 answer_ /* uint startedAt */ /* uint updatedAt */ /* uint80 answeredInRound */,
            ,
            ,

        ) = dataFeed.latestRoundData();

        s.orakl.answer = answer_;
        s.orakl.roundId = roundId_;

        return answer_;
    }

    function decimals(address _proxy) public view returns (uint8) {
        IAggregator dataFeed = IAggregator(_proxy);
        return dataFeed.decimals();
    }
}
