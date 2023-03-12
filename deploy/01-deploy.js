const {
  networkConfig,
  developmentChains,
  INITIAL_SUPPLY,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");
require("dotenv").config();
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log("......................");
  log("Minting your token...");
  log(network.name);

  const ourToken = await deploy("ourToken", {
    from: deployer,
    log: true,
    args: [INITIAL_SUPPLY],
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  log("contract deployed at ", ourToken.address);

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(ourToken.address, [INITIAL_SUPPLY]);
  }
};

module.exports.tags = ["all"];
