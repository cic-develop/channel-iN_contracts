import { ethers } from "ethers";
import Caver from "caver-js";
import { GetDbFacet__factory } from "../typechain-types";
import "dotenv/config";

const RPC_HOST = process.env.KLAYTN_NODE_MAIN_ENDPOINT;
const CHANNELIN_ADDRESS = "0xe98F1e28179DE7b678DD8146a5A33C588514415a";

async function main() {
  // const channelin = new provider.Contract(
  //   CHANNELIN_ADDRESS,
  //   GetDbFacet__factory.abi,
  //   provider
  // );

  await channelin.getTest2().then((res) => {
    console.log(String(res));
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
