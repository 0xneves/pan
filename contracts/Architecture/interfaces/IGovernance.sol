// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IGovernance {
    function create(address[] memory addrs) external returns (bytes32);

    function join(bytes32 partyId, uint256 index) external;

    function votePassed(bytes32 partyId) external view returns (bool);

    function votesOf(bytes32 partyId) external view returns (uint256);

    function currentVotersOf(
        bytes32 partyId
    ) external view returns (uint256[] memory);

    function lastVoteOf(address addr) external view returns (uint256);

    function getMembersOf(
        bytes32 partyId
    ) external view returns (address[] memory);

    function getTotalMembersOf(bytes32 partyId) external view returns (uint256);

    function addrIsIndexed(
        bytes32 partyId,
        uint256 index,
        address addr
    ) external view returns (bool);

    function addrIsOperator(
        bytes32 partyId,
        address addr
    ) external view returns (bool);

    function getAddrIndex(
        bytes32 partyId,
        address addr
    ) external view returns (uint256 index);
}
