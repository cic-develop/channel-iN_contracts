// import { ethers } from "hardhat";
// import { FacetCutAction, getSelectors } from "../../libraries/diamond";

// export async function initDiamond() {
//   const diamond = '0x911846be441B0aBFd688D696F1CDE0F56ea3E25b'
//   const accounts = await ethers.getSigners();
//   const contractOwner = accounts[0];

//   const ConstantFacet = await ethers.getContractAt(
//     "ConstantFacet",
//     diamond
//   );
//   let tx;
//   let receipt;
//   // call to init function
//   let functionCall = ConstantFacet.setContract('db', '');
//   tx = await diamondCut.diamondCut(
//     cut,
//     await diamondInit.getAddress(),
//     functionCall
//   );
//   console.log("Diamond cut tx: ", tx.hash);
//   receipt = await tx.wait();
//   if (!receipt?.status) {
//     throw Error(`Diamond upgrade failed: ${tx.hash}`);
//   }

//   console.log("Completed diamond cut");
//   return await diamond.getAddress();
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// initDiamond().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
