// SPDX-License-Identifier: None
pragma solidity ^0.8.22;

interface Iitem {
    function mint(
        address _addr,
        uint _id,
        uint _amount,
        bytes calldata _data
    ) external;
}
