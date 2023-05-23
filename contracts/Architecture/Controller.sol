// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./Governance.sol";
import "./Deployer.sol";

import "./interfaces/INFT.sol";
import "./interfaces/IHelper.sol";
import "./interfaces/IController.sol";
import "./helpers/Epoch.sol";

error AllMustVote();
error AlreadyAccepted();
error AlreadyUpgraded();
error InvalidMember();
error InvalidIndex();
error NotEveryoneVoted();

contract Controller is IController, IERC165, Governance, Deployer, Epoch {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) public {
        // vote must be approved, meaning all members have joined and voted
        if (!voteIsAccepted(partyId)) {
            revert AllMustVote();
        }

        // msg.sender must be in the group
        if (!addrIsMember(partyId, msg.sender)) {
            revert InvalidMember();
        }

        // deploy the NFT contract
        _deploy(
            partyId,
            address(this),
            getTotalMembersOf(partyId),
            name,
            symbol,
            uri
        );
    }

    function senderIsIndexed(
        bytes32 partyId,
        uint256 index
    ) public view returns (bool) {
        address[] memory members = getMembersOf(partyId);
        return
            msg.sender == members[index] ||
            msg.sender == IHelper(members[index]).owner();
    }

    function vote(bytes32 partyId, uint256 index) public {
        // Governance - Must be valid voter
        if (!addrIsMember(partyId, msg.sender)) {
            revert InvalidMember();
        }

        // Governance - Not your index
        if (!senderIsIndexed(partyId, index)) {
            revert InvalidIndex();
        }

        // Governance - Vote already accepted
        if (voteIsAccepted(partyId)) {
            revert AlreadyAccepted();
        }

        // Epoch - Can only happen one Epoch at a time.
        if (_contractOf(partyId).getLastEpoch() == currentEpoch()) {
            revert AlreadyUpgraded();
        }

        _vote(partyId, index);
    }

    function voteIsAccepted(bytes32 partyId) public view returns (bool) {
        return 2 ** _getTotalMembersOf(partyId) == votesFor(partyId);
    }

    function getHealthFrom(bytes32 partyId) public view returns (uint256) {
        return _contractOf(partyId).getHealth();
    }

    function getMissingHealthFrom(
        bytes32 partyId
    ) public view returns (uint256) {
        return _contractOf(partyId).getMissingHealth();
    }

    function getCurrentEpoch() public view returns (uint256) {
        return currentEpoch();
    }

    function getVirtualEpoch() public view returns (uint256) {
        return virtualEpoch();
    }

    function getLifeSpan() public view returns (uint256) {
        return lifespan();
    }

    function getDeployTime() public view returns (uint256) {
        return deployTime();
    }

    function _contractOf(bytes32 partyId) internal view returns (INFT) {
        return INFT(deployedAddr(partyId));
    }

    function supportsInterface(
        bytes4 interfaceID
    ) external pure override(IERC165, IController) returns (bool) {
        return
            interfaceID == type(IERC165).interfaceId ||
            interfaceID == type(IController).interfaceId;
    }
}
