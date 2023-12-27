// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage, Modifier} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibDistribute} from "../libraries/LibDistribute.sol";

contract DistributeFacet is Modifier {
    // 
    function migrateBalance(address _facet, address _tokenAddr, uint _amount) external onlyDev {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        IERC20(_tokenAddr).transfer(msgsender, _amount);
        s.distributeBalances[_tokenAddr] += _amount;
    }


    
    // 




}
