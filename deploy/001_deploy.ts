import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, getChainId } = hre;

  const { diamond } = deployments;

  const { deployer, diamondAdmin } = await getNamedAccounts();

  await diamond.deploy("CHANNELIN", {
    from: deployer,
    owner: diamondAdmin,
    facets: ["AdminFacet", "ConstantFacet", "P0Facet", "AienMintFacet"],
  });
};
export default func;

// async ({getNamedAccounts, deployments, getChainId}) => {
//     const {diamond} = deployments;
//     const {deployer, diamondAdmin} = await getNamedAccounts();
//     await diamond.deploy('ADiamondContract', {
//       from: diamondAdmin, // this need to be the diamondAdmin for upgrade
//       owner: diamondAdmin,
//       facets: ['NewFacet', 'Facet2', 'Facet3'],
//     });
//   };
