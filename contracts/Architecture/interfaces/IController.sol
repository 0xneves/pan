// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IStories} from "./IStories.sol";

interface IController {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) external;

    function vote(bytes32 partyId, bytes4 funId, uint256 index) external;

    function resetVotes(bytes32 partyId) external;

    function propose(
        bytes32 partyId,
        IStories.ProposalType proposalType,
        address member,
        string memory data
    ) external;

    function getHealth(bytes32 partyId) external view returns (uint256);

    function getMissingHealth(bytes32 partyId) external view returns (uint256);

    function getCurrentEpoch() external view returns (uint256);

    function getLifeSpan() external view returns (uint256);

    function getDeployTime() external view returns (uint256);

    function getDeployedAddr(bytes32 partyId) external view returns (address);

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
