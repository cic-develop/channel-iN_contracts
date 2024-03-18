// import { HardhatRuntimeEnvironment } from "hardhat/types";
// import { DeployFunction } from "hardhat-deploy/types";
// import fs from "fs";
// import { ethers, upgrades } from "hardhat";

// const testAddr = "0x02fe42876323F870b466422efee0f31E107d4695";
// const liveAddr = "";
// // async function main() {
// //   const contractName = "P2";
// //   const Contract = await ethers.getContractFactory(contractName);
// //   const contract = await upgrades.deployProxy(Contract, []);
// //   await contract.waitForDeployment();

// //   console.log("P2 deployed to : ", await contract.getAddress());
// // }

// //// upgrade contract

// async function main() {
//   const TargetContract = await ethers.getContractFactory("P2");
//   const p2 = await upgrades.upgradeProxy(
//     "0x02fe42876323F870b466422efee0f31E107d4695",
//     TargetContract
//   );
//   console.log("Upgraded", await p2.getAddress());
// }

// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
