// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IStories {
    enum ProposalType {
        Name,
        Symbol,
        URI
    }
    struct MyStories {
        string story;
        string name;
        string symbol;
        string uri;
    }

    function getStory(
        bytes32 partyId,
        uint256 epoch
    ) external view returns (string memory);

    function _getStory(
        bytes32 partyId,
        uint256 epoch
    ) external view returns (MyStories memory);
}
