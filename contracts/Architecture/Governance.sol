// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./helpers/Math.sol";
import "./Party.sol";
import "./Context.sol";

error AlreadyVoted();

contract Governance is Context, Party, Math {
    mapping(bytes32 => mapping(address => bool)) private belong;
    mapping(bytes32 => uint256) private votes;

    function _vote(bytes32 partyId, uint256 index) internal {
        if (hasVoted(votes[partyId], index)) {
            revert AlreadyVoted();
        }

        votes[partyId] += 2 ** index;
    }

    function votesFor(bytes32 partyId) public view returns (uint256) {
        return votes[partyId];
    }

    function alreadyVoted(
        bytes32 partyId
    ) public view returns (uint256[] memory) {
        return decompose(votes[partyId]);
    }

    function addrIsMember(
        bytes32 partyId,
        address addr
    ) public view returns (bool) {
        return belong[partyId][addr];
    }

    function getMembersOf(
        bytes32 partyId
    ) public view returns (address[] memory) {
        return _getMembersOf(partyId);
    }

    function getTotalMembersOf(bytes32 partyId) public view returns (uint256) {
        return _getTotalMembersOf(partyId);
    }
}
