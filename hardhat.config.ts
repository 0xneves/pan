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
  "https://eth-mainnet.g.alchemy.com/v2/dVfk0JbYlzHpMU000lJZ39hrwf0f818u";

const POLYGON_MAINNET =
  "https://polygon-mainnet.g.alchemy.com/v2/5H1rrcYkvbpo6sTW4hrOhH7glU6GHQ4v";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "hardhat",
  // gasReporter: {
  //   enabled: true,
  // },
  etherscan: {
    apiKey: "5RNGZU9UMNDE2G7DID88S2WSD5G9WSIHKJ",
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
    },
  },
};

export default config;
