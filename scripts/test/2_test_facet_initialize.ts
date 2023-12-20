import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "../libraries/diamond";

import fs from "fs";

const run = async () => {
  const constant = await JSON.parse(fs.readFileSync("constants.json", "utf8"));
  const constantFacet = await ethers.getContractAt(
    "ConstantFacet",
    constant.test.contract.diamond
  );

  let arr: any = [];
  Object.keys(constant.test.legacy).forEach(async (key) => {
    console.log(key);
    console.log(constant.test.legacy[key]);
    arr.push([key, constant.test.legacy[key]]);
  });

  for (let i = 0; i < arr.length; i++) {
    const tx = await constantFacet.setContract(arr[i][0], arr[i][1]);

    let receipt = await tx.wait();
    if (!receipt.status) {
      throw Error(`constants setting failed: ${tx.hash}`);
    }
    console.log(`${arr[i][0]}: ${arr[i][1]}}`);
  }

  //   Object.keys(constant.test.legacy).forEach(async (key) => {
  //     console.log(key, " : ", constant.test.legacy[key]);
  //     constantFacet.getContract(key).then((res) => {
  //       console.log("onChain");
  //       console.log(key, " : ", res.toString());
  //     });
  //   });
};

run();
