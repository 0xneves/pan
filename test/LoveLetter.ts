import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract } from "ethers";
const { ethers } = require("hardhat");

// Describing this contract
describe("LoveLetter", function () {
  let LoveLetter: Contract;
  let owner: SignerWithAddress;
  const addressOne = "0x203520F4ec42Ea39b03F62B20e20Cf17DB5fdfA7";
  const addressTwo = "0xdB3c617cDd2fBf0bb4309C325F47678e37F096D9";

  before(async () => {
    owner = await ethers.getImpersonatedSigner("0x79f67f689B9925710D4ddA2A39d680E9CeA61C81");
    const Factory = await ethers.getContractFactory("LoveLetter", owner);
    const contract = await Factory.deploy(owner.address, owner.address);
    LoveLetter = await contract.deployed();

    console.log("Deploying contract...with owner: ", owner.address);
  });

  it("Should fetch the partners", async function () {
    const data = await LoveLetter.us();
    expect(data[0]).to.equal(owner.address);
    expect(data[1]).to.equal(owner.address);
    expect(data[2]).to.equal(1);
  });

  it("Should set the URI", async function () {
    const uri = "New URI";
    expect(
      await LoveLetter.updateRelation("", uri, {
        value: ethers.utils.parseEther("1"),
      })
    ).to.be.ok;
    const _uri = await LoveLetter.tokenURI(1);
    expect(_uri).to.equal(uri + "1");
  });
});
