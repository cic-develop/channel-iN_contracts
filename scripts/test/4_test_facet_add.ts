import { ethers } from "hardhat";
import { deployFacets, removeFacets } from "../libraries/deploy_facet";

import fs from "fs";

const run = async () => {
  const constant = await JSON.parse(fs.readFileSync("constants.json", "utf8"));

  await deployFacets("P0Facet", constant.test.contract.diamond);
};

run();
