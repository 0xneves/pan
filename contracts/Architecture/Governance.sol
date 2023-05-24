// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./helpers/Math.sol";
import "./Stories.sol";
import "./Party.sol";

error AlreadyInTheParty();
error AlreadyVoted();
error NotInvited();

contract Governance is Party, Math, Stories {
    mapping(bytes32 => mapping(address => bool)) private belong;
    mapping(bytes32 => mapping(bytes4 => uint256)) private votes;

    function create(address[] memory addrs) public returns (bytes32) {
        bytes32 partyId = genPartyId(addrs, address(this));

        _create(partyId, addrs);

        return partyId;
    }

    function join(bytes32 partyId, uint256 index) public {
        if (!_canJoin(partyId, index, msg.sender)) {
            revert NotInvited();
        }

        if (belong[partyId][msg.sender]) {
            revert AlreadyInTheParty();
        }

        belong[partyId][msg.sender] = true;
    }

    function _vote(bytes32 partyId, bytes4 funId, uint256 index) internal {
        if (hasVoted(votes[partyId][funId], index)) {
            revert AlreadyVoted();
        }

        votes[partyId][funId] += 2 ** index;
    }

    function _voteIsAccepted(
        bytes32 partyId,
        bytes4 funId
    ) internal view returns (bool) {
        return 2 ** _getTotalMembersOf(partyId) == votes[partyId][funId];
    }

    function votesFor(
        bytes32 partyId,
        bytes4 funId
    ) public view returns (uint256) {
        return votes[partyId][funId];
    }

    function alreadyVoted(
        bytes32 partyId,
        bytes4 funId
    ) public view returns (uint256[] memory) {
        return decompose(votes[partyId][funId]);
    }

    function addrIsIndexed(
        bytes32 partyId,
        uint256 index,
        address addr
    ) public view returns (bool) {
        address[] memory members = _getMembersOf(partyId);
        return
            addr == members[index] || addr == IHelper(members[index]).owner();
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

    function getAddrIndex(
        bytes32 partyId,
        address addr
    ) public view returns (uint256 index) {
        return _getAddrIndex(partyId, addr);
    }
}
