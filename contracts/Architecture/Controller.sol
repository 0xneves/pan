// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./Governance.sol";
import "./Deployer.sol";
import "./Context.sol";

import "./NFT.sol";

import "./interfaces/IHelper.sol";
import "./interfaces/IController.sol";
import "./helpers/Epoch.sol";

error AlreadyAccepted();
error AlreadyUpgraded();
error NotEveryoneVoted();
error InvalidMember();
error InvalidIndex();

contract Controller is
    IController,
    IERC165,
    Context,
    Governance,
    Deployer,
    Epoch
{
    function deploy() public {
        // _deploy();
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
        return 2 ** _contractOf(partyId).getTotalMembers() == votesFor(partyId);
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

    function _contractOf(bytes32 partyId) internal view returns (IHelper) {
        return IHelper(deployedAddr(partyId));
    }

    function supportsInterface(
        bytes4 interfaceID
    ) external pure override(IERC165, IController) returns (bool) {
        return
            interfaceID == type(IERC165).interfaceId ||
            interfaceID == type(IController).interfaceId;
    }
}
