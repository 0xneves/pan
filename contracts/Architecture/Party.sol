// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IHelper.sol";

error AddressIsNotInParty();
error PartyAlreadyCreated();
error PartyTooEmptyOrTooFull();

contract Party {
    mapping(bytes32 => address[]) private members;

    function _create(bytes32 partyId, address[] memory addrs) internal {
        if (_getTotalMembersOf(partyId) > 0) {
            revert PartyAlreadyCreated();
        }

        // is this maximum ok?
        if (addrs.length == 0 || addrs.length > 255) {
            revert PartyTooEmptyOrTooFull();
        }

        members[partyId] = addrs;
    }

    function _addrIsIndexed(
        bytes32 partyId,
        uint256 index,
        address member
    ) internal view returns (bool) {
        return
            member == members[partyId][index] ||
            member == IHelper(members[partyId][index]).owner();
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

    function _getAddrIndex(
        bytes32 partyId,
        address addr
    ) internal view returns (uint256 index) {
        address[] memory partners = _getMembersOf(partyId);

        for (index = 0; index < partners.length; ) {
            if (addr == partners[index]) {
                return index;
            }
            unchecked {
                index++;
            }
        }

        revert AddressIsNotInParty();
    }
}
