// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Epoch {
    uint256 private DEPLOY_TIME;
    uint256 private EPOCH = 12 weeks;

    constructor() {
        DEPLOY_TIME = block.timestamp;
    }

    function _currentEpoch() internal view returns (uint256) {
        return (_lifespan() / EPOCH) + 1;
    }

    function _lifespan() internal view returns (uint256) {
        return (block.timestamp - DEPLOY_TIME);
    }

    function _deployTime() internal view returns (uint256) {
        return DEPLOY_TIME;
    }
}
