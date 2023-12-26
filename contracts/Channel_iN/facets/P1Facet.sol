// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IP1} from "../interfaces/IP1.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IP2} from "../interfaces/IP2.sol";
import {IDB} from "../interfaces/IDB.sol";
import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";

contract P1Facet {
    function P1_deposit(uint _amount) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IERC20(s.contracts["per"]).transferFrom(
            msgsender,
            s.contracts["p1"],
            _amount
        );
        IP1(s.contracts["p1"]).diamond_P1_deposit(msgsender, _amount);
    }

    function P1_reDeposit() external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IP1(s.contracts["p1"]).diamond_P1_reDposit(msgsender);
    }

    function P1_harvest() external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        uint256 reward = IP1(s.contracts["p1"]).diamond_P1_harvest(msgsender);
    }

    function P1_pendingReward(
        address _user,
        uint _withdrawBlock
    ) external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return
            IP1(s.contracts["p1"]).diamond_P1_pendingReward(
                _user,
                _withdrawBlock
            );
    }

    function P1_addPower(uint _aienId, uint _usePower) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IP1(s.contracts["p1"]).diamond_P1_addPower(
            msgsender,
            _aienId,
            _usePower
        );
    }

    function P1_widthdraw(uint _amount) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        uint256 reward = IP1(s.contracts["p1"]).diamond_P1_widthdraw(
            msgsender,
            _amount
        );
    }

    function P1_widthdrawConfirm(uint _pendingId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        uint256 reward = IP1(s.contracts["p1"]).diamond_P1_widthdrawConfirm(
            msgsender,
            _pendingId
        );
    }

    function P1_widthdrawCancel(uint _pendingId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        uint256 reward = IP1(s.contracts["p1"]).diamond_P1_widthdrawCancel(
            msgsender,
            _pendingId
        );
    }

    function P1_widthdrawCancelConfirm(uint _pendingId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        uint256 reward = IP1(s.contracts["p1"])
            .diamond_P1_widthdrawCancelConfirm(msgsender, _pendingId);
    }

    function P1_getPoolData() external view returns (uint, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP1(s.contracts["p1"]).diamond_P1_getPoolData();
    }

    function P1_getUserData()
        external
        view
        returns (uint, uint, uint, uint, uint)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        return IP1(s.contracts["p1"]).diamond_P1_getUserData(msgsender);
    }

    function P1_getUnstakeData()
        external
        view
        returns (IP1.PendingInfo[] memory)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        return IP1(s.contracts["p1"]).diamond_P1_getUnstakeData(msgsender);
    }

    function testCalling() external view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP1(s.contracts["p1"]).testDiamondCall();
    }
}
