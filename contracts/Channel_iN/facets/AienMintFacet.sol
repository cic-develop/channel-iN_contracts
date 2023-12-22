// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibAienMint} from "../libraries/LibAienMint.sol";

/**
@dev Aien Mint Facet Contract
 */

contract AienMintFacet {
    // aien mint functions
    function aiMint() external {
        address msgsender = LibMeta.msgSender();
        LibAienMint._aiMint(msgsender);
    }

    function pfMint(uint _pfId) external {
        address msgsender = LibMeta.msgSender();
        LibAienMint._pfMint(msgsender, _pfId);
    }

    function defaultMint() external {
        address msgsender = LibMeta.msgSender();
        LibAienMint._defaultMint(msgsender);
    }

    // image chage functions
    function defaultSetImage(uint _aienId) external {
        address msgsender = LibMeta.msgSender();
        LibAienMint._defaultSetImage(msgsender, _aienId);
    }

    function aiSetImage(uint _aienId) external {
        address msgsender = LibMeta.msgSender();
        LibAienMint._aiSetImage(msgsender, _aienId);
    }

    function pfSetImage(uint _aienId, uint _pfId) external {
        address msgsender = LibMeta.msgSender();
        LibAienMint._pfSetImage(msgsender, _aienId, _pfId);
    }
}
