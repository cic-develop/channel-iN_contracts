import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import fs from "fs";
import { network } from "hardhat";
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, getChainId } = hre;

  const { diamond } = deployments;

  const { deployer, diamondAdmin } = await getNamedAccounts();

  await diamond.deploy("CHANNELIN", {
    from: deployer,
    owner: diamondAdmin,
    facets: [
      "AdminFacet",
      "ConstantFacet",
      "P0Facet",
      "AienMintFacet",
      "P1Facet",
      "P2Facet",
      "DistributeFacet",
      "FrontFacet",
      "P3Facet",
    ],
  });

  const networkName = deployments.getNetworkName();
  if (networkName == "test") {
    const abi = JSON.parse(
      fs.readFileSync("./deployments/test/CHANNELIN.json", "utf8")
    ).abi;

    fs.writeFileSync("./CHANNELIN_DEV.json", JSON.stringify(abi));
  } else {
    const abi = JSON.parse(
      fs.readFileSync("./deployments/live/CHANNELIN.json", "utf8")
    ).abi;

    fs.writeFileSync("./CHANNELIN_LIVE.json", JSON.stringify(abi));
  }
};
export default func;
