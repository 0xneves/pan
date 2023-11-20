// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface INFT {
    function upgrade(uint256 index) external payable;

    function kill() external;

    function getHealth() external view returns (uint256);

    function getMissingHealth() external view returns (uint256);

    function getLastEpoch() external view returns (uint256);

    function getTotalMembers() external view returns (uint256);

    function getAddrIndex(address addr) external view returns (uint256);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
