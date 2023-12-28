// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IP2_Admin {
    // layer Settings
    function _layer_setting(
        uint _layerNumber,
        uint _fromP2PerPercent,
        uint _fromP2UsdtPercent,
        uint _dailyReward_percent,
        uint _add_dailyReward_Percent,
        bool _isOpen
    ) external;

    function diamond_P2_BlockUser(
        address _user,
        bool _isBlock,
        string memory _why
    ) external;

    function diamond_P2_setMaxLimit(uint _maxLimit) external;
}
