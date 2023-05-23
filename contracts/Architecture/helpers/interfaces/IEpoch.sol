// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IEpoch {
    function currentEpoch() external view returns (uint256);

    function virtualEpoch() external view returns (uint256);

    function lifespan() external view returns (uint256);
}
