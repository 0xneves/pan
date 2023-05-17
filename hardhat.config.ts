import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "@nomiclabs/hardhat-truffle5";
import "hardhat-gas-reporter";
import "@nomiclabs/hardhat-etherscan";
import dotenv from "dotenv";
dotenv.config();

const ETHEREUM_MAINNET = "https://eth-mainnet.g.alchemy.com/v2/dVfk0JbYlzHpMU000lJZ39hrwf0f818u";

const POLYGON_MAINNET = "https://polygon-mainnet.g.alchemy.com/v2/5H1rrcYkvbpo6sTW4hrOhH7glU6GHQ4v";

//const { PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "hardhat",
  // gasReporter: {
  //   enabled: true,
  // },
  etherscan: { // PolygonScan actually
    apiKey: "U5CSWDUSV4PWJXAK23SUK6MVITQSVYZXV7",
  },
  networks: {
    hardhat: {
      forking: {
        url: ETHEREUM_MAINNET,
        blockNumber: 16492821,
      },
      allowUnlimitedContractSize: true,
    },
    polygon: {
      url: POLYGON_MAINNET,
      //accounts: [`${PRIVATE_KEY}`],
    },
  },
};

export default config;
