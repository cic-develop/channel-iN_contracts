import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config"; // import .env variables
import "./tasks";
import "@openzeppelin/hardhat-upgrades";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  networks: {
    cypress: {
      url: process.env.KLAYTN_NODE_MAIN_ENDPOINT,
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
      gasPrice: 25000000000,
    },
    cypress_test: {
      url: process.env.KLAYTN_NODE_TEST_ENDPOINT,
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
      gasPrice: 25000000000,
    },
  },
};

export default config;
