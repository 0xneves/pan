// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Party {
    mapping(bytes32 => address[]) private members;

    function create(address[] memory addrs) public returns (bytes32) {}

    function join(bytes32 partyId, uint256 index) public {}

    function _getMembersOf(
        bytes32 partyId
    ) internal view returns (address[] memory) {
        return members[partyId];
    }

    function _getTotalMembersOf(
        bytes32 partyId
    ) internal view returns (uint256) {
        return members[partyId].length;
    }
}
