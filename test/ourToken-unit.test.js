const { assert, expect } = require("chai");
const { network, getNamedAccounts, ethers, deployments } = require("hardhat");
const {
  developmentChains,
  INITIAL_SUPPLY,
} = require("../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("ourToken Unit test", () => {
      let deployer;
      let user;
      let ourToken;
      beforeEach(async () => {
        deployer = (await getNamedAccounts()).deployer;
        user = (await getNamedAccounts()).user;
        await deployments.fixture("all");
        ourToken = await ethers.getContract("ourToken", deployer);
      });

      it("was deployed", () => {
        assert(ourToken.address);
      });

      describe("Constructor", () => {
        it("Should have the correct value of initial supply", async () => {
          const actual_totalSupply = await ourToken.totalSupply();
          assert(actual_totalSupply.toString(), INITIAL_SUPPLY);
        });

        it("Initialize the token with the correct name and symbol", async () => {
          const actual_name = await ourToken.name();
          const expected_name = "ourToken";
          const actual_symbol = await ourToken.symbol();
          const expected_symbol = "OT";
          assert(actual_name, expected_name);
          assert(actual_symbol, expected_symbol);
        });
      });

      describe("Transfer function", () => {
        let amount_to_transfer;
        beforeEach(() => {
          amount_to_transfer = ethers.utils.parseEther("10"); //transfer of 10 OT
        });
        it("should be able to transfer tokens to an address", async () => {
          const tx_response = await ourToken.transfer(user, amount_to_transfer);
          const tx_receipt = await tx_response.wait(1);
          const user_balance = await ourToken.balanceOf(user);
          assert(user_balance, amount_to_transfer);
        });

        it("should emit an event when tokens are transfered", async () => {
          await expect(ourToken.transfer(user, amount_to_transfer)).to.emit(
            ourToken,
            "Transfer"
          );
        });
      });

      describe("Allowance", () => {
        const amount_to_approve = ethers.utils.parseEther("10");
        let playerToken;
        beforeEach(async () => {
          playerToken = await ethers.getContract("ourToken", user);
        });
        it("should accurate set the allowance, should approve other address to spend token and should correctly update the allowance after they've been spent", async () => {
          const txResponse = await ourToken.approve(user, amount_to_approve);
          const txReceipt = await txResponse.wait(1);
          const approved_amount = await ourToken.allowance(deployer, user);
          assert(approved_amount, amount_to_approve);
          await playerToken.transferFrom(deployer, user, approved_amount);
          const user_balance = await playerToken.balanceOf(user);
          assert(user_balance, approved_amount);
          const updated_approved_amount = await ourToken.allowance(
            deployer,
            user
          );
          assert(updated_approved_amount.toString(), "0");
        });

        it("doesn't allow an unapproved member to do transfer", async () => {
          await expect(
            playerToken.transferFrom(deployer, user, amount_to_approve)
          ).to.be.revertedWith("ERC20: insufficient allowance");
        });

        it("should emit an event when an approval occurs", async () => {
          await expect(ourToken.approve(user, amount_to_approve)).to.emit(
            ourToken,
            "Approval"
          );
        });

        it("should not permit to spend more token than the one approved", async () => {
          const too_token_than_approved = ethers.utils.parseEther("20");
          const txResponse = await ourToken.approve(user, amount_to_approve);
          const txReceipt = await txResponse.wait(1);
          await expect(
            playerToken.transferFrom(deployer, user, too_token_than_approved)
          ).to.be.revertedWith("ERC20: insufficient allowance");
        });
      });
    });
