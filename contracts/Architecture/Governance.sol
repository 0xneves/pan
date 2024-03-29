// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./helpers/Math.sol";
import "./Party.sol";

error AlreadyJoined();
error AlreadyVoted();
error NotInvited();

contract Governance is Party, Math {
    mapping(bytes32 => mapping(address => bool)) private operator;
    mapping(bytes32 => uint256) private votes;
    mapping(bytes32 => uint256) private lastVote;

    function create(address[] memory addrs) public returns (bytes32) {
        bytes32 partyId = genPartyId(addrs, address(this));

        _create(partyId, addrs);

        return partyId;
    }

    function join(bytes32 partyId, uint256 index) public {
        if (!_addrIsIndexed(partyId, index, msg.sender)) {
            revert NotInvited();
        }

        if (addrIsOperator(partyId, msg.sender)) {
            revert AlreadyJoined();
        }

        operator[partyId][msg.sender] = true;
    }

    function _vote(bytes32 partyId, uint256 index, uint256 epoch) internal {
        if (lastVoteOf(partyId) != epoch) {
            votes[partyId] = 2 ** index;
        }

        if (_hasVoted(votes[partyId], index)) {
            revert AlreadyVoted();
        }

        votes[partyId] += 2 ** index;

        lastVote[partyId] == epoch;
    }

    function _resetVotes(bytes32 partyId) internal {
        votes[partyId] = 0;
    }

    function votePassed(bytes32 partyId) public view returns (bool) {
        return 2 ** _getTotalMembersOf(partyId) == votes[partyId];
    }

    function votesOf(bytes32 partyId) public view returns (uint256) {
        return votes[partyId];
    }

    function currentVotersOf(
        bytes32 partyId
    ) public view returns (uint256[] memory) {
        return decompose(votes[partyId]);
    }

    function lastVoteOf(bytes32 partyId) public view returns (uint256) {
        return lastVote[partyId];
    }

    function getMembersOf(
        bytes32 partyId
    ) public view returns (address[] memory) {
        return _getMembersOf(partyId);
    }

    function getTotalMembersOf(bytes32 partyId) public view returns (uint256) {
        return _getTotalMembersOf(partyId);
    }

    function addrIsIndexed(
        bytes32 partyId,
        uint256 index,
        address addr
    ) public view returns (bool) {
        return _addrIsIndexed(partyId, index, addr);
    }

    function addrIsOperator(
        bytes32 partyId,
        address addr
    ) public view returns (bool) {
        return operator[partyId][addr];
    }

    function getAddrIndex(
        bytes32 partyId,
        address addr
    ) public view returns (uint256 index) {
        return _getAddrIndex(partyId, addr);
    }
}
