// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AppStorage, Modifiers, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";

contract ConstantFacet is Modifiers {
    function getContract(string memory _name) external view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.contracts[_name];
    }

    function setContract(
        string memory _name,
        address _addr
    ) external onlyOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.contracts[_name] = _addr;
    }
}
