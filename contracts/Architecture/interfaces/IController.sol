// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IController {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) external;

    function senderIsIndexed(
        bytes32 partyId,
        uint256 index
    ) external view returns (bool);

    function vote(bytes32 partyId, uint256 index) external;

    function voteIsAccepted(bytes32 partyId) external view returns (bool);

    function getHealthFrom(bytes32 partyId) external view returns (uint256);

    function getMissingHealthFrom(
        bytes32 partyId
    ) external view returns (uint256);

    function getCurrentEpoch() external view returns (uint256);

    function getVirtualEpoch() external view returns (uint256);

    function getLifeSpan() external view returns (uint256);

    function getDeployTime() external view returns (uint256);

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
