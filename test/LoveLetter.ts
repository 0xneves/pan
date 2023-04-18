import { expect } from "chai";
const { ethers } = require("hardhat");

// Describing this contract
describe("LoveLetter", function () {
  // Describing the deployment
  async function deployment() {
    const initialAmount = ethers.utils.parseEther("0.1");

    const addressOne = "0x203520F4ec42Ea39b03F62B20e20Cf17DB5fdfA7";
    const addressTwo = "0xdB3c617cDd2fBf0bb4309C325F47678e37F096D9";

    const owner = await ethers.getImpersonatedSigner(
      "0x79f67f689B9925710D4ddA2A39d680E9CeA61C81"
    );

    console.log("Deploying contract...with owner: ", owner.address);

    const LoveLetter = await ethers.getContractFactory("LoveLetter", owner);
    const contract = await LoveLetter.deploy(addressOne, addressTwo, {
      value: initialAmount,
    });
    await contract.deployed();

    console.log("Contract deployed to:", contract.address);

    return { contract, owner, addressOne, addressTwo };
  }

  // Testing the contract functions
  describe("Test the contract", function () {
    it("Should deploy the contract", async function () {
      // Fetch Errors
      try {
        // Deployment
        const { contract, owner, addressOne, addressTwo } = await deployment();
        const ownerOf = await contract.ownerOf(1);
        expect(ownerOf).to.equal(contract.address);

        // Global contract deployed
        // Fetch NFT statuses
        context("Should fetch the partners", async function () {
          const data = await contract.getPartnersData();
          expect(data[0]).to.equal(addressOne);
          expect(data[1]).to.equal(addressTwo);
          expect(data[2]).to.equal(1);
        });
      } catch (e) {
        console.log(e);
      }
    });
  });
});
