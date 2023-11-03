// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AppStorage {
    mapping(address => User) users;
    mapping(string => Constant) constants;
}

struct User {
    address _userAddr;
    string _nation;
    string _useWalletType;
    bool _isBlack;
}

struct Constant {
    string _contractName;
    address _contractAddr;
    bytes _contractAbi;
    uint _version;
}

