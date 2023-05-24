// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./Governance.sol";
import "./Deployer.sol";

import "./interfaces/INFT.sol";
import "./interfaces/IController.sol";
import "./helpers/Epoch.sol";

error AllMustVote();
error AlreadyAccepted();
error AlreadyUpgraded();
error InvalidCaller();
error InvalidMember();
error InvalidIndex();
error NotEnoughVotes();
error NotEveryoneVoted();

contract Controller is IController, IERC165, Governance, Deployer, Epoch {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) public {
        bytes4 funId = this.deploy.selector;

        // vote must be approved, meaning all members have joined and voted
        if (!_voteIsAccepted(partyId, funId)) {
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

    function vote(bytes32 partyId, bytes4 funId, uint256 index) public {
        // Governance - Vote already accepted
        if (_voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }

        // Governance - Must be valid voter
        if (!addrIsMember(partyId, msg.sender)) {
            revert InvalidMember();
        }

        // Governance - Not your index
        if (!addrIsIndexed(partyId, index, msg.sender)) {
            revert InvalidIndex();
        }

        // Epoch - Can only happen one Epoch at a time.
        if (_contractOf(partyId).getLastEpoch() == currentEpoch()) {
            revert AlreadyUpgraded();
        }

        _vote(partyId, funId, index);
    }

    function proposeName(
        bytes32 partyId,
        uint256 index,
        address member,
        string memory newName
    ) public {
        address addr = deployedAddr(partyId);
        bytes4 funId = INFT(addr).proposeName.selector;

        if (msg.sender != addr || msg.sender != member) {
            revert InvalidCaller();
        }

        if (voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }

        if (!addrIsIndexed(partyId, index, member)) {
            revert InvalidIndex();
        }

        _proposeStories(partyId, getCurrentEpoch(), newName, "", "");
    }

    function proposeSymbol(
        bytes32 partyId,
        uint256 index,
        address member,
        string memory newSymbol
    ) public {
        address addr = deployedAddr(partyId);
        bytes4 funId = INFT(addr).proposeSymbol.selector;

        if (msg.sender != addr || msg.sender != member) {
            revert InvalidCaller();
        }

        if (voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }

        if (!addrIsIndexed(partyId, index, member)) {
            revert InvalidIndex();
        }

        _proposeStories(partyId, getCurrentEpoch(), "", newSymbol, "");
    }

    function proposeURI(
        bytes32 partyId,
        uint256 index,
        address member,
        string memory newURI
    ) public {
        address addr = deployedAddr(partyId);
        bytes4 funId = INFT(addr).proposeURI.selector;

        if (msg.sender != addr || msg.sender != member) {
            revert InvalidCaller();
        }

        if (voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }

        if (!addrIsIndexed(partyId, index, member)) {
            revert InvalidIndex();
        }

        _proposeStories(partyId, getCurrentEpoch(), "", "", newURI);
    }

    function voteIsAccepted(
        bytes32 partyId,
        bytes4 funId
    ) public view returns (bool) {
        return _voteIsAccepted(partyId, funId);
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

    function getDeployedAddr(bytes32 partyId) public view returns (address) {
        return deployedAddr(partyId);
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
