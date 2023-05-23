// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Epoch {
    uint256 private DEPLOY_TIME;
    uint256 private EPOCH = 12 weeks;

    constructor() {
        DEPLOY_TIME = block.timestamp;
    }

    function currentEpoch() internal view returns (uint256) {
        return (lifespan() / EPOCH) + 1;
    }

    function virtualEpoch() internal view returns (uint256) {
        return currentEpoch() + 1;
    }

    function lifespan() internal view returns (uint256) {
        return (block.timestamp - DEPLOY_TIME);
    }

    function deployTime() internal view returns (uint256) {
        return DEPLOY_TIME;
    }
}
