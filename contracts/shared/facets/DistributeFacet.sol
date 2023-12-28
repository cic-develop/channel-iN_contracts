// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage, Modifiers} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibDistribute} from "../libraries/LibDistribute.sol";

contract DistributeFacet is Modifiers {
    // 1차로 Distribute facet에 balance를 모으고
    // 패싯이 변경되었을때 transfer하여 balance migrate하기 위한 함수
    function Distribute_Transfer_Balance(
        address _facet,
        address _tokenAddr,
        uint _amount
    ) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        IERC20(_tokenAddr).transfer(msgsender, _amount);
    }

    function Distribute_p0LvUpDistribute(
        address _agency,
        uint _agencyAmount,
        address _influencer,
        uint _influencerAmount,
        uint _totalAmount
    ) external {
        LibDistribute.p0LvUpDistribute(
            _agency,
            _agencyAmount,
            _influencer,
            _influencerAmount,
            _totalAmount
        );
    }

    function Distribute_swapToDistribute() external {
        LibDistribute.swapToDistribute();
    }
}
