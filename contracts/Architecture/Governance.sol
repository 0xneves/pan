// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./helpers/Math.sol";
import "./Party.sol";

error InvalidMember(address);

contract Governance is Party {
    mapping(bytes32 => mapping(address => bool)) private belong;
    mapping(bytes32 => uint256) private votes;

    function _vote(
        bytes32 partyId,
        uint256 index,
        address addr,
        uint256 currEpoch
    ) internal {
        // Must be valid voter
        if (!validMember(partyId, index)) {
            revert InvalidMember(msg.sender);
        }

        // Can only happen during an Epoch. Resets every new Epoch.
    }

    function votesFor(bytes32 partyId) public view returns (uint256) {}

    function whoVotedFor(
        bytes32 partyId
    ) public view returns (uint256[] memory) {
        // Lib - Decompose the votes map
        // This - Return every index of the party that voted
    }

    function addressBelongs(
        address addr,
        bytes32 partyId
    ) public view returns (bool) {}

    function validMember(
        bytes32 partyId,
        uint256 index
    ) public view returns (bool) {
        address[] memory partners = membersOf(partyId);
        return msg.sender == partners[index];
    }

    function myIndex() public view returns (uint256) {}

    function indexOfAddr() public view returns (uint256) {}
}
