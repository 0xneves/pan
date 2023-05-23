// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Deployer {
    mapping(bytes32 => address) private deployed;

    function deploy(bytes32 partyId, uint256 index) public {}

    function deployedAddr(bytes32 partyId) public view returns (address) {
        return deployed[partyId];
    }
}
