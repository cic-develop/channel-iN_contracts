// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage, LibAppStorage} from "../../shared/libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IDB} from "../interfaces/IDB.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibDistribute} from "../../shared/libraries/LibDistribute.sol";

library LibAienMint {
    // mint events
    event Aien_DefaultMint_Event(address indexed to, uint indexed aienId);

    event Aien_AiMint_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed payment
    );

    event Aien_PfMint_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed perfId
    );

    // setImage events
    event Aien_DefaultSetImage_Event(address indexed to, uint indexed aienId);

    event Aien_AiSetImage_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed payment
    );

    event Aien_PfSetImage_Event(
        address indexed to,
        uint indexed aienId,
        uint indexed perfId
    );

    modifier onlyFirstMint() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IERC721(s.contracts["aien"]).balanceOf(LibMeta.msgSender()) == 0,
            "already minted"
        );
        _;
    }

    function _aiMint(address _sender) internal onlyFirstMint returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint id = IERC721(s.contracts["aien"]).nextTokenId();
        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["team"],
            s.aienMintFee
        );
        IERC721(s.contracts["aien"]).safeMintByMinter(_sender);
        IDB(s.contracts["db"]).setAien(id);

        // emit AiMint(_sender, id);
        emit Aien_AiMint_Event(_sender, id, s.aienMintFee);

        return id;
    }

    function _defaultMint(
        address _sender
    ) internal onlyFirstMint returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint id = IERC721(s.contracts["aien"]).nextTokenId();

        IERC721(s.contracts["aien"]).safeMintByMinter(_sender);
        IDB(s.contracts["db"]).setAien(id);

        // emit DefaultMint(_sender, id);
        emit Aien_DefaultMint_Event(_sender, id);
        return id;
    }

    function _pfMint(
        address _sender,
        uint _pfId
    ) internal onlyFirstMint returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        require(
            IERC721(s.contracts["perfriends"]).ownerOf(_pfId) == _sender,
            "not owner"
        );
        // PF의 등급이 상위 3등급인지 체크 (unique, legendary, myth)
        require(
            IDB(s.contracts["db"]).getPfGrade(_pfId) > 4,
            "at least PF grade 5"
        );

        uint id = IERC721(s.contracts["aien"]).nextTokenId();
        IDB(s.contracts["db"]).setAien(id);
        IDB(s.contracts["db"]).usePFimg(id, _pfId);
        IERC721(s.contracts["aien"]).safeMintByMinter(_sender);

        // emit PfMint(_sender, id, _pfId);
        emit Aien_PfMint_Event(_sender, id, _pfId);

        return id;
    }

    function _defaultSetImage(address _sender, uint _aienId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IERC721(s.contracts["aien"]).ownerOf(_aienId) == _sender,
            "not owner"
        );

        // emit DefaultSetImage(_sender, _aienId);
        emit Aien_DefaultSetImage_Event(_sender, _aienId);
    }

    function _aiSetImage(address _sender, uint _aienId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IERC721(s.contracts["aien"]).ownerOf(_aienId) == _sender,
            "not owner"
        );

        IERC20(s.contracts["per"]).transferFrom(
            _sender,
            s.contracts["team"],
            s.aienMintFee
        );

        // emit AiSetImage(_sender, _aienId);
        emit Aien_AiSetImage_Event(_sender, _aienId, s.aienMintFee);
    }

    function _pfSetImage(address _sender, uint _aienId, uint _pfId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IERC721(s.contracts["aien"]).ownerOf(_aienId) == _sender,
            "not owner"
        );
        require(
            IERC721(s.contracts["perfriends"]).ownerOf(_pfId) == _sender,
            "not owner"
        );
        // PF의 등급이 상위 3등급인지 체크 (unique, legendary, myth)
        require(
            IDB(s.contracts["db"]).getPfGrade(_pfId) > 4,
            "at least PF grade 5"
        );

        IDB(s.contracts["db"]).usePFimg(_aienId, _pfId);

        // emit PfSetImage(_sender, _aienId, _pfId);
        emit Aien_PfSetImage_Event(_sender, _aienId, _pfId);
    }
}
