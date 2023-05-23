// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IHealth.sol";

contract Health {
    function health() public view returns (uint256) {}

    function missingHealth() public view returns (uint256) {}

    function virtualHealth() public view returns (uint256) {}
}
