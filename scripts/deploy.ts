import { Contract } from "ethers";
const { ethers } = require("hardhat");

// Describing this contract
async function main() {
  const [owner] = await ethers.getSigners();
  console.log("Deploying contract...with owner: ", owner.address);

  const addressOne = "0x203520f4ec42ea39b03f62b20e20cf17db5fdfa7";
  const addressTwo = "0xdb3c617cdd2fbf0bb4309c325f47678e37f096d9";

  const LoveLetter = await ethers.getContractFactory("LoveLetter", owner);
  const contract = await LoveLetter.deploy(addressOne, addressTwo);
  await contract.deployed();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
