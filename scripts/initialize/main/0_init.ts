import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "../../libraries/diamond";

export async function initDiamond() {}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
initDiamond().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
