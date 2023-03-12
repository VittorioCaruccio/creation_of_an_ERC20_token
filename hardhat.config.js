/** @type import('hardhat/config').HardhatUserConfig */
require("hardhat-deploy");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL;

module.exports = {
  solidity: "0.8.18",

  networks: {
    hardhat: {
      chainId: 31337,
    },
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
      BlockConfirmations: 6,
      saveDeployments: true,
    },
    polygon: {
      url: POLYGON_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 137,
      BlockConfirmations: 6,
      saveDeployments: true,
    },
  },

  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },

  namedAccounts: {
    deployer: {
      31337: 0,
      5: 0,
      137: 0,
    },
    user: {
      31337: 1,
    },
  },
};
