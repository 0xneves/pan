// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Party {
    mapping(bytes32 => address[]) private members;

    function create(address[] memory addrs) public returns (bytes32) {}

    function join(bytes32 partyId, uint256 index) public {}

    function membersOf(bytes32 partyId) public view returns (address[] memory) {
        return members[partyId];
    }

    
}
