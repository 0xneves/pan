// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IHelper.sol";

error PartyAlreadyCreated();

contract Party {
    mapping(bytes32 => address[]) private members;

    function _create(bytes32 partyId, address[] memory addrs) internal {
        if (_getTotalMembersOf(partyId) > 0) {
            revert PartyAlreadyCreated();
        }

        members[partyId] = addrs;
    }

    function _canJoin(
        bytes32 partyId,
        uint256 index,
        address addr
    ) internal view returns (bool) {
        return
            addr == members[partyId][index] ||
            addr == IHelper(members[partyId][index]).owner();
    }

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
