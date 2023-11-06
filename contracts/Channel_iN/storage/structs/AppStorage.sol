// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AppStorage {
    mapping(string => Constant) constants;
}
struct Constant {
    string _contractName;
    address _contractAddr;
    bytes _contractAbi;
    uint _version;
}
