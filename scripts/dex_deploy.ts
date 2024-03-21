// import fs from "fs";
// import { ethers, upgrades } from "hardhat";
// // import { writeDeployment } from "./helper";
// // const testAddr = "0x02fe42876323F870b466422efee0f31E107d4695";
// // const liveAddr = "";
// async function main() {
//   const contractName = "PerDexFactory";

//   //   console.log(ethers.provider._networkName);
//   const Contract = await ethers.getContractFactory(contractName);
//   const contract = await upgrades.deployProxy(Contract, []);
//   await contract.waitForDeployment();

//   fs.writeFileSync(
//     `./${ethers.provider._networkName}-${contractName}.json`,
//     JSON.stringify(contract)
//   );

//   console.log("DEX deployed to : ", await contract.getAddress());
// }

// // //// upgrade contract

// // async function main() {
// //   const TargetContract = await ethers.getContractFactory("DEX");
// //   const p2 = await upgrades.upgradeProxy(
// //     "0x02fe42876323F870b466422efee0f31E107d4695",
// //     TargetContract
// //   );
// //   console.log("Upgraded", await p2.getAddress());
// // }

// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });

import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

//
// import { toNumber } from "ethers";

const deployFunction: DeployFunction = async function ({
  ethers,
  deployments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();
  const { dev, protocolFeeTo } = await getNamedAccounts();

  await deploy("PerDexFactory", {
    from: deployer,
    proxy: {
      owner: dev,
      proxyContract: "OpenZeppelinTrasnparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [protocolFeeTo],
        },
      },
    },
    log: true,
    gasPrice: "100000000000",
  });
};

export default deployFunction;
deployFunction.tags = ["PerDexFactory"];
