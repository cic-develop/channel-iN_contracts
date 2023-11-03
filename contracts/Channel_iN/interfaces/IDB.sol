// SPDX-License-Identifier: None
pragma solidity ^0.8.9;

/**
@dev 기존 작성된 legacy 코드를 migrate 하기전 임시로 사용하는 interface
**/
interface IDB {
    function getInfluencerItem(uint _id) external view returns (address);

    function _getMedataMargin() external view returns (uint, uint, uint);
}
