import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "dotenv/config";
import "./tasks";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-deploy";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
      {
        version: "0.8.18",
      },
      {
        version: "0.8.20",
      },
      {
        version: "0.8.22",
      },
      {
        version: "0.5.6",
      },
    ],
  },
  namedAccounts: {
    deployer: 0,
  },
  networks: {
    live: {
      url: process.env.KLAYTN_NODE_MAIN_ENDPOINT,
      accounts: [process.env.LIVE_PRIV_KEY || ""],
      chainId: 8217,
      gasPrice: 25000000000,
    },
    test: {
      url: process.env.KLAYTN_NODE_TEST_ENDPOINT,
      accounts: [process.env.TEST_PRIV_KEY || ""],
      chainId: 8217,
      gasPrice: 25000000000,
    },
  },
};
export default config;
