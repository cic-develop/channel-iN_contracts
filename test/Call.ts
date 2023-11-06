import { ethers } from "ethers";
import { GetDbFacet__factory } from "../typechain-types";
import "dotenv/config";

const RPC_HOST = process.env.KLAYTN_NODE_MAIN_ENDPOINT;
const CHANNELIN_ADDRESS = "0xe98F1e28179DE7b678DD8146a5A33C588514415a";

async function main() {
  const provider = new ethers.JsonRpcProvider(RPC_HOST);
  const channelin = new ethers.Contract(
    CHANNELIN_ADDRESS,
    GetDbFacet__factory.abi,
    provider
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
