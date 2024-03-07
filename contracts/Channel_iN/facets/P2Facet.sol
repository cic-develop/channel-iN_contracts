// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {LibP2} from "../libraries/LibP2.sol";
import {IDB} from "../interfaces/IDB.sol";
import "../../shared/libraries/LibEnumerableSet.sol";

contract P2Facet {
    event P2_Staking_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed layer
    );
    event P2_UnStaking_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed layer
    );
    event P2_Harvest_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed layer,
        uint ousdt,
        uint per
    );

    function P2_staking(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        uint _aienLevel = P2_getAienLevel(_aienId);
        IP2(s.contracts["p2"]).diamond_P2_deposit(msgsender, _aienId);
        IERC721(s.contracts["aien"]).safeTransferFrom(
            msgsender,
            s.contracts["p2"],
            _aienId
        );

        emit P2_Staking_Event(msgsender, _aienId, _aienLevel);
    }

    function P2_unStaking(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        uint _aienLevel = P2_getAienLevel(_aienId);
        (uint per, uint ousdt) = IP2(s.contracts["p2"]).pendingReward(
            _aienId,
            _aienLevel,
            0
        );

        emit P2_UnStaking_Event(msgsender, _aienId, _aienLevel);
        emit P2_Harvest_Event(msgsender, _aienId, _aienLevel, per, ousdt);

        IP2(s.contracts["p2"]).diamond_P2_withdraw(msgsender, _aienId);
    }

    function P2_harvest(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        uint _aienLevel = P2_getAienLevel(_aienId);
        (uint per, uint ousdt) = IP2(s.contracts["p2"]).pendingReward(
            _aienId,
            _aienLevel,
            0
        );
        emit P2_Harvest_Event(msgsender, _aienId, _aienLevel, per, ousdt);
        IP2(s.contracts["p2"]).diamond_P2_harvest(msgsender, _aienId);
    }

    function P2_getUserInfo()
        external
        view
        returns (
            LibP2.UserLoadData memory,
            LibP2.AienLoadData[] memory,
            LibP2.LayerLoadData[] memory
        )
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        (
            IP2.UserLoadData memory userData,
            IP2.AienLoadData[] memory aienData,
            IP2.LayerLoadData[] memory layerData
        ) = IP2(s.contracts["p2"]).diamond_P2_getUserInfo(msgsender);
        return (userData, aienData, layerData);
    }

    function P2_getLayerData(
        uint _number
    ) public view returns (uint, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).diamond_P2_getLayerData(_number);
    }

    function P2_getAienLevel(uint _aienId) public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["db"]).getAienLevel(_aienId);
    }

    function P2_usdtBalance() public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).P2_usdtBalance();
    }

    function P2_perBalance() public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).P2_perBalance();
    }

    function P2_maxStakingLimit() public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).MAX_STAKING_LIMIT();
    }

    function P2_layers(uint _number) public view returns (IP2.Layer memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).layers(_number);
    }
}
