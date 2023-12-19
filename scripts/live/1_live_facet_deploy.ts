import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "../libraries/diamond";

import fs from "fs";

const run = async () => {
  const constant = await JSON.parse(fs.readFileSync("constants.json", "utf8"));

  // deploy facets
  const cut = [];

  const FacetNames = ["AdminFacet", "P0Facet", "ConstantFacet"];
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName);
    const facet = await Facet.deploy();
    await facet.waitForDeployment();
    // const facetContract = await ethers.getContractAt(FacetName, await facet.getAddress())
    console.log(`${FacetName} deployed: ${await facet.getAddress()}`);
    cut.push({
      facetAddress: await facet.getAddress(),
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(Facet),
    });
  }

  // upgrade diamond with facets
  console.log("");
  console.log("Diamond Cut:", cut);
  const diamondCut = await ethers.getContractAt(
    "IDiamondCut",
    constant.live.contract.diamond
  );
  let tx;
  let receipt;

  tx = await diamondCut.diamondCut(cut, ethers.ZeroAddress, "0x");

  console.log("Diamond cut tx: ", tx.hash);
  receipt = await tx.wait();
  if (!receipt?.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }
};

run();
