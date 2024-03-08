// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage, P2_Layer} from "../../shared/libraries/LibAppStorage.sol";
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
        uint baseReward,
        uint plusReward
    );

    function P2_staking(uint _aienId) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // address msgsender = LibMeta.msgSender();
        uint _aienLevel = P2_getAienLevel(_aienId);
        LibP2.diamond_P2_deposit(msg.sender, _aienId);
        IERC721(s.contracts["aien"]).safeTransferFrom(
            msg.sender,
            s.contracts["p2balance"],
            _aienId
        );

        emit P2_Staking_Event(msg.sender, _aienId, _aienLevel);
    }

    function P2_unStaking(uint _aienId) external {
        // address msgsender = LibMeta.msgSender();

        uint _aienLevel = P2_getAienLevel(_aienId);
        (uint base, uint plus) = LibP2.__P2_Pending_Reward(
            _aienId,
            _aienLevel
        );

        emit P2_UnStaking_Event(msg.sender, _aienId, _aienLevel);
        emit P2_Harvest_Event(msg.sender, _aienId, _aienLevel, base, plus);

        LibP2.diamond_P2_withdraw(msg.sender, _aienId);
    }

    function P2_harvest(uint _aienId) external {
        // address msgsender = LibMeta.msgSender();
        uint _aienLevel = P2_getAienLevel(_aienId);
        (uint base, uint plus) = LibP2.__P2_Pending_Reward(
            _aienId,
            _aienLevel
        );
        emit P2_Harvest_Event(msg.sender, _aienId, _aienLevel, base, plus);
        LibP2.diamond_P2_harvest(msg.sender, _aienId);
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
        // address msgsender = LibMeta.msgSender();

        (
            LibP2.UserLoadData memory userData,
            LibP2.AienLoadData[] memory aienData,
            LibP2.LayerLoadData[] memory layerData
        ) = LibP2.diamond_P2_getUserInfo(msg.sender);
        return (userData, aienData, layerData);
    }

    function P2_getLayerData(
        uint _number
    ) public view returns (uint, uint, uint) {
        
        return LibP2.diamond_p2_getLayerData(_number);
    }

    function P2_getAienLevel(uint _aienId) public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return IDB(s.contracts["db"]).getAienLevel(_aienId);
    }

    function P2_baseBalance() public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.P2_baseBalance;
    }

    function P2_plusBalance() public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.P2_plusBalance;
    }

    function P2_maxStakingLimit() public view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.P2_MAX_STAKING_LIMIT;
    }

    function P2_layers(uint _number) public view returns (P2_Layer memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.p2_layers[_number];
    //     return IP2(s.contracts["p2"]).layers(_number);
    }

    function P2_beforeOpenLayer(uint _layer) public view returns (uint) {
        // AppStorage storage s = LibAppStorage.diamondStorage();
        // LibP2.diamond_p2_beforeLayer(_layer);

        return LibP2.diamond_p2_beforeLayer(_layer);

    }
}
