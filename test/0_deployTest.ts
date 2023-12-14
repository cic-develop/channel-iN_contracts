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
    // RubyonFacet = await ethers.getContractAt("RubyonFacet", diamondAddress);
  });

  it("constant_contract function call test", async () => {
    await ConstantFacet.setContract("main", diamondAddress);

    console.log(await ConstantFacet.getContract("main"));
  });
});
