// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {NFT} from "./NFT.sol";

error AlreadyDeployed();

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
        if (deployed[partyId] != address(0)) {
            revert AlreadyDeployed();
        }

        NFT UntilDeathKnocks = new NFT(
            partyId,
            controllerAddr,
            totalMembers,
            name,
            symbol,
            uri
        );
        deployed[partyId] = address(UntilDeathKnocks);
    }

    function deployedAddr(bytes32 partyId) internal view returns (address) {
        return deployed[partyId];
    }
}
