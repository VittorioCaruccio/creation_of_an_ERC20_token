const networkConfig = {
  31337: {
    name: "localhost",
  },
  5: {
    name: "goerli",
  },
};

const developmentChains = ["hardhat", "localhost"];

const INITIAL_SUPPLY = "1000000000000000000000000"; //1000000 token

module.exports = { networkConfig, developmentChains, INITIAL_SUPPLY };
