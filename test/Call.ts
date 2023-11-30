/* global describe it before ethers */

import {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets,
} from "../scripts/libraries/diamond";
import { deployDiamond } from "../scripts/deploy";
import { assert } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("DiamondTest", async function () {
  let diamondAddress: string;
  let diamondCutFacet: Contract;
  let diamondLoupeFacet: Contract;
  let ownershipFacet: Contract;
  let ConstantFacet: Contract;
  let RubyonFacet: Contract;
  let tx;
  let receipt;
  let result;
  const addresses: string[] = [];
  // const accounts =  ethers.getSigners();

  before(async function () {
    diamondAddress = await deployDiamond();
    console.log({ diamondAddress });
    diamondCutFacet = await ethers.getContractAt(
      "DiamondCutFacet",
      diamondAddress
    );
    diamondLoupeFacet = await ethers.getContractAt(
      "DiamondLoupeFacet",
      diamondAddress
    );
    ownershipFacet = await ethers.getContractAt(
      "OwnershipFacet",
      diamondAddress
    );

    ConstantFacet = await ethers.getContractAt("ConstantFacet", diamondAddress);
    RubyonFacet = await ethers.getContractAt("RubyonFacet", diamondAddress);
  });

  it("facet function call test", async () => {
    await ConstantFacet.setContract(
      "rainforest",
      "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
    );
    await ConstantFacet.setContract(
      "rubyon",
      "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
    );
    console.log(await ConstantFacet.getContract("rainforest"));
    console.log(await RubyonFacet.getNameItem(diamondAddress, 0));
  });
});
