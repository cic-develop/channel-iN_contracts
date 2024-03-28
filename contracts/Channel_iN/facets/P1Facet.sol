// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IP1} from "../interfaces/IP1.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IP2} from "../interfaces/IP2.sol";
import {IDB} from "../interfaces/IDB.sol";
import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";

contract P1Facet {
    event P1_Staking_Event(address indexed to, uint indexed stakeAmount);
    event P1_RewardStaking_Event(address indexed to, uint indexed stakeAmount);

    event P1_Harvest_Event(address indexed to, uint indexed rewardAmount);

    event P1_AddPower_Event(address indexed to, uint indexed usePower);

    event P1_UnStaking_Event(
        address indexed to,
        uint indexed unStakeAmount,
        uint indexed pendingId,
        uint burnPower
    );
    event P1_UnstakingConfirm_Event(
        address indexed to,
        uint indexed unStakeAmount,
        uint indexed pendingId
    );
    event P1_UnstakingCancel_Event(
        address indexed to,
        uint indexed unStakeAmount,
        uint indexed pendingId
    );
    event P1_UnstakingCancelConfirm_Event(
        address indexed to,
        uint indexed unStakeAmount,
        uint indexed pendingId
    );

    function P1_staking(uint _amount) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        IP1(s.contracts["p1"]).diamond_P1_deposit(msgsender, _amount);
        IERC20(s.contracts["per"]).transferFrom(
            msgsender,
            s.contracts["p1"],
            _amount
        );

        emit P1_Staking_Event(msgsender, _amount);
    }

    function P1_rewardStaking() external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IP1(s.contracts["p1"]).diamond_P1_reDposit(msgsender);
        uint reward = IP1(s.contracts["p1"]).diamond_P1_pendingReward(
            msgsender,
            0
        );

        emit P1_RewardStaking_Event(msgsender, reward);
    }

    function P1_harvest() external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IP1(s.contracts["p1"]).diamond_P1_harvest(msgsender);
        uint reward = IP1(s.contracts["p1"]).diamond_P1_pendingReward(
            msgsender,
            0
        );

        emit P1_Harvest_Event(msgsender, reward);
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

        emit P1_AddPower_Event(msgsender, _usePower);
    }

    function P1_unstaking(uint _amount) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        (uint burnPower, uint pendingId) = IP1(s.contracts["p1"])
            .diamond_P1_widthdraw(msgsender, _amount);

        emit P1_UnStaking_Event(msgsender, _amount, pendingId, burnPower);
    }

    function P1_unstakingConfirm(uint _pendingId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        (uint reward, uint pendingId) = IP1(s.contracts["p1"])
            .diamond_P1_widthdrawConfirm(msgsender, _pendingId);

        emit P1_UnstakingConfirm_Event(msgsender, reward, pendingId);
    }

    function P1_unstakingCancel(uint _pendingId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        (uint256 reward, uint pendingId) = IP1(s.contracts["p1"])
            .diamond_P1_widthdrawCancel(msgsender, _pendingId);

        emit P1_UnstakingCancel_Event(msgsender, reward, pendingId);
    }

    function P1_unstakingCancelConfirm(uint _pendingId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        (uint256 reward, uint pendingId) = IP1(s.contracts["p1"])
            .diamond_P1_widthdrawCancelConfirm(msgsender, _pendingId);

        emit P1_UnstakingCancelConfirm_Event(msgsender, reward, pendingId);
    }

    /**
    P1 _ get functions
     */
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

    function P1_getTimeLockInfo() external view returns (uint16, uint16) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            IP1(s.contracts["p1"]).unStakeTimeLock(),
            IP1(s.contracts["p1"]).unStakeCancelTimeLock()
        );
    }

    function P1_getUnstakeData_user(
        address _addr
    ) external view returns (IP1.PendingInfo[] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // address msgsender = LibMeta.msgSender();
        return IP1(s.contracts["p1"]).diamond_P1_getUnstakeData(_addr);
    }
}
