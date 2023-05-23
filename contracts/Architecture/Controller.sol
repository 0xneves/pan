// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Governance.sol";
import "./Deployer.sol";
import "./Context.sol";

import "./interfaces/INFT.sol";
import "./interfaces/IOwnable.sol";
import "./interfaces/IController.sol";
import "./helpers/Epoch.sol";

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

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
    function vote(bytes32 partyId, uint256 index) public {
        // Governance - Must be valid voter
        if (!addressBelongs(partyId, msg.sender)) {
            revert InvalidMember();
        }

        // Governance - Not your index
        if (!senderIsIndexed(partyId, index)) {
            revert InvalidIndex();
        }

        // Governance - Vote already accepted
        if (voteAccepted(partyId)) {
            revert AlreadyAccepted();
        }

        // Epoch - Can only happen one Epoch at a time.
        if (_contractOf(partyId).getLastEpoch() == currentEpoch()) {
            revert AlreadyUpgraded();
        }

        _vote(partyId, index);
    }

    function voteAccepted(bytes32 partyId) public view returns (bool) {
        return 2 ** _contractOf(partyId).getTotalMembers() == votesFor(partyId);
    }

    function health(bytes32 partyId) public view returns (uint256) {
        return _contractOf(partyId).getHealth();
    }

    function missingHealth(bytes32 partyId) public view returns (uint256) {
        return _contractOf(partyId).getMissingHealth();
    }

    function virtualHealth(bytes32 partyId) public view returns (uint256) {
        return _contractOf(partyId).getVirtualHealth();
    }

    function senderIsIndexed(
        bytes32 partyId,
        uint256 index
    ) public view returns (bool) {
        address[] memory members = membersOf(partyId);
        return
            msg.sender == members[index] ||
            msg.sender == IOwnable(members[index]).owner();
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
