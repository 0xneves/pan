// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IGovernance {
    function create(address[] memory addrs) external returns (bytes32);

    function join(bytes32 partyId, uint256 index) external;

    function votesFor(
        bytes32 partyId,
        bytes4 funId
    ) external view returns (uint256);

    function alreadyVoted(
        bytes32 partyId,
        bytes4 funId
    ) external view returns (uint256[] memory);

    function addrIsIndexed(
        bytes32 partyId,
        uint256 index,
        address addr
    ) external view returns (bool);

    function addrIsOperator(
        bytes32 partyId,
        address addr
    ) external view returns (bool);

    function getMembersOf(
        bytes32 partyId
    ) external view returns (address[] memory);

    function getTotalMembersOf(bytes32 partyId) external view returns (uint256);

    function getAddrIndex(
        bytes32 partyId,
        address addr
    ) external view returns (uint256 index);
}
