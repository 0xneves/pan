import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "@nomiclabs/hardhat-truffle5";
import "hardhat-gas-reporter";
import "@nomiclabs/hardhat-etherscan";

const ETHEREUM_MAINNET =
  "https://eth-mainnet.g.alchemy.com/v2/j3OuXRcqfffV7WHPHN2G-1JcHCaOJL6H";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  gasReporter: {
    enabled: true,
  },
  networks: {
    hardhat: {
      forking: {
        url: `${ETHEREUM_MAINNET}`,
        blockNumber: 16500000,
      },
      chainId: 1,
      allowUnlimitedContractSize: true,
    },
  },
};

export default config;
