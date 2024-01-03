// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IP2} from "../interfaces/IP2.sol";
import {IDB} from "../interfaces/IDB.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract P2Facet {
    function P2_staking(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();
        IP2(s.contracts["p2"]).diamond_P2_deposit(msgsender, _aienId);
        IERC721(s.contracts["aien"]).safeTransferFrom(
            msgsender,
            s.contracts["p2"],
            _aienId
        );
    }

    function P2_unstaking(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IP2(s.contracts["p2"]).diamond_P2_withdraw(msgsender, _aienId);
    }

    function P2_harvest(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address msgsender = LibMeta.msgSender();

        IP2(s.contracts["p2"]).diamond_P2_harvest(msgsender, _aienId);
    }

    function P2_getUserInfo()
        external
        view
        returns (
            IP2.UserLoadData memory,
            IP2.AienLoadData[] memory,
            IP2.LayerLoadData[] memory
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
    ) external view returns (uint, uint, uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).diamond_P2_getLayerData(_number);
    }

    function P2_getAienLevel(uint _aienId) external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["db"]).getAienLevel(_aienId);
    }

    function P2_usdtBalance() external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).P2_usdtBalance();
    }

    function P2_perBalance() external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).P2_perBalance();
    }

    function P2_maxStakingLimit() external view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).MAX_STAKING_LIMIT();
    }

    function P2_layers(uint _number) external view returns (IP2.Layer memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IP2(s.contracts["p2"]).layers(_number);
    }
}
