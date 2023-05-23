// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IEpoch.sol";

contract Epoch {
    uint256 private DEPLOY_TIME;
    uint256 private EPOCH = 12 weeks;

    constructor() {
        DEPLOY_TIME = block.timestamp;
    }

    function currentEpoch() public view returns (uint256) {
        return (lifespan() / EPOCH) + 1;
    }

    function virtualEpoch() public view returns (uint256) {
        return currentEpoch() + 1;
    }

    function lifespan() public view returns (uint256) {
        return (block.timestamp - DEPLOY_TIME);
    }

    function deployTime() public view returns (uint256) {
        return DEPLOY_TIME;
    }
}
