// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface INFT {
    function upgrade() external payable;

    function kill() external;

    function changeName() external;

    function changeBaseURI() external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
