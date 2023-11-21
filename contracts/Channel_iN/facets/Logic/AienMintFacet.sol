// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IAien.sol";

contract AienMintFacet {
    IAien public AIEN;

    event DefaultMint(address indexed _to, uint indexed _tokenId);
    event AiMint(address indexed _to, uint indexed _tokenId);
    event PfMint(
        address indexed _to,
        uint indexed _tokenId,
        uint indexed _pfId
    );

    event DefaultSetImage(address indexed _to, uint indexed _tokenId);
    event AiSetImage(address indexed _to, uint indexed _tokenId);
    event PfSetImage(
        address indexed _to,
        uint indexed _tokenId,
        uint indexed _pfId
    );
    event PfDeleteImage(uint indexed _tokenId, uint indexed _pfId);

    modifier onlyFirstMint() {
        require(AIEN.balanceOf(msg.sender) == 0, "already minted");
        _;
    }

    ////////////////////////////////////////////////mint functions
    function defaultMint() external onlyFirstMint {}

    function aiMint() public onlyFirstMint returns (uint) {}

    function pfMint(uint _pfId) public onlyFirstMint returns (uint) {}

    ////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////image change functions
    function aiSetImage(uint _aienId) public {}

    function pfSetImage(uint _aienId, uint _pfId) public {}

    ////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////admin functions
    function setAiMintFee(uint _fee) public onlyOwner {}

    function _setAienInstance(address _aien) public onlyOwner {
        AIEN = IAien(_aien);
    }
}
