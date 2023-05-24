// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IStories} from "./interfaces/IStories.sol";

contract Stories {
    mapping(bytes32 => mapping(uint256 => IStories.MyStories)) private stories;

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

    function _writeStory(
        bytes32 partyId,
        uint256 epoch,
        string memory newStory
    ) internal {
        stories[partyId][epoch].story = newStory;
    }

    function getStory(
        bytes32 partyId,
        uint256 epoch
    ) public view returns (string memory) {
        return stories[partyId][epoch].story;
    }

    function getStories(
        bytes32 partyId,
        uint256 epoch
    ) public view returns (IStories.MyStories memory) {
        return stories[partyId][epoch];
    }
}
