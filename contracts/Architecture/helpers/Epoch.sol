// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IEpoch.sol";

contract Epoch {
    uint256 EPOCH = 12 weeks;

    function currentEpoch() public view returns (uint256) {
        return (lifespan() / EPOCH) + 1;
    }

    function virtualEpoch() public view returns (uint256) {
        return currentEpoch() + 1;
    }

    function lifespan() public view returns (uint256) {
        return (block.timestamp - CLOCK);
    }
}
