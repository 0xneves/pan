import { Contract } from "ethers";
const { ethers } = require("hardhat");

// Describing this contract
async function main() {
  const [owner] = await ethers.getSigners();
  console.log("Deploying contract...with owner: ", owner.address);

  const addressOne = "0xCE70F940929C5a2a9c41CFCc227cA3bdC0e4C0D7";
  const addressTwo = "0xB388324Def8d56513D35d7bE0547bB4f4cAE7183";

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
