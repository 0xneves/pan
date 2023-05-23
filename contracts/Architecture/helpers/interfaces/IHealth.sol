// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IHealth {
    function health() external view returns (uint256);

    function missingHealth() external view returns (uint256);

    function virtualHealth() external view returns (uint256);
}
