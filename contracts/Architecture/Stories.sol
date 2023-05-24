// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Stories {
    mapping(bytes32 => mapping(uint256 => MyStories)) private stories;

    struct MyStories {
        string story;
        string name;
        string symbol;
        string uri;
    }

    function _proposeStories(
        bytes32 partyId,
        uint256 epoch,
        string memory newName,
        string memory newSymbol,
        string memory newURI
    ) internal {
        if (bytes(newName).length > 0) {
            stories[partyId][epoch].name = newName;
        }
        if (bytes(newSymbol).length > 0) {
            stories[partyId][epoch].symbol = newSymbol;
        }
        if (bytes(newURI).length > 0) {
            stories[partyId][epoch].uri = newURI;
        }
    }

    function getStories(
        bytes32 partyId,
        uint256 epoch
    ) public view returns (MyStories memory) {
        return stories[partyId][epoch];
    }
}
