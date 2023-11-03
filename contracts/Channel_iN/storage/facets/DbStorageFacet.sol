// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {LibDiamond} from "../../libraries/LibDiamond.sol";
// import "../structs/DbStorage.sol";

// contract DbStorageFacet {
//     DbStorage internal s;

//     function dbStorage() internal pure returns (DbStorage storage ds) {
//         assembly {
//             ds.slot := 0
//         }
//     }
// }