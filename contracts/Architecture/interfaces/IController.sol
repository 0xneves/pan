// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IController {
    function vote(bytes32 partyId, uint256 index) external;

    function voteAccepted(bytes32 partyId) external view returns (bool);

    function health(bytes32 partyId) external view returns (uint256);

    function missingHealth(bytes32 partyId) external view returns (uint256);

    function virtualHealth(bytes32 partyId) public view returns (uint256)

    function senderIsIndexed(
        bytes32 partyId,
        uint256 index
    ) external view returns (bool);

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
