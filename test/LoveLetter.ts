import { expect } from "chai";
import { Contract } from "ethers";
const { ethers } = require("hardhat");

// Describing this contract
describe("LoveLetter", function () {
  let LoveLetter: Contract;
  const initialAmount = ethers.utils.parseEther("0.01");
  const addressOne = "0x203520F4ec42Ea39b03F62B20e20Cf17DB5fdfA7";
  const addressTwo = "0xdB3c617cDd2fBf0bb4309C325F47678e37F096D9";

  beforeEach(async () => {
    const owner = await ethers.getImpersonatedSigner("0x79f67f689B9925710D4ddA2A39d680E9CeA61C81");
    const Factory = await ethers.getContractFactory("LoveLetter", owner);
    const contract = await Factory.deploy(addressOne, addressTwo);
    LoveLetter = await contract.deployed();

    console.log("Deploying contract...with owner: ", owner.address);
  });

  it("Should fetch the partners", async function () {
    const data = await LoveLetter.us();
    expect(data[0]).to.equal(addressOne);
    expect(data[1]).to.equal(addressTwo);
    expect(data[2]).to.equal(1);
  });
});
