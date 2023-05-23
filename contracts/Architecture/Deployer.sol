// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Deployer {
    mapping(bytes32 => address) private deployed;

    function _deploy(
        bytes32 partyId,
        address controllerAddr,
        uint256 totalMembers,
        string memory name,
        string memory symbol,
        string memory uri
    ) internal {
        NFT newContractB = new NFT(
            controllerAddr,
            totalMembers,
            name,
            symbol,
            uri
        );
        deployed[partyId] = address(newContractB);
    }

    function deployedAddr(bytes32 partyId) internal view returns (address) {
        return deployed[partyId];
    }
}
