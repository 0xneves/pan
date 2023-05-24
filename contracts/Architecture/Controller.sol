// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./Governance.sol";
import "./Deployer.sol";

import "./interfaces/INFT.sol";
import "./interfaces/IController.sol";
import "./helpers/Epoch.sol";

error AlreadyAccepted();
error AlreadyDeployed();
error AlreadyUpgraded();
error InvalidCaller();
error InvalidCallerWithIndex();
error InvalidDeployFunId(bytes4);
error InvalidProposalType();
error NotEnoughVotes();
error NotEveryoneVoted();

contract Controller is IController, IERC165, Governance, Deployer, Epoch {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) public {
        if (!_voteIsAccepted(partyId, this.deploy.selector)) {
            revert NotEnoughVotes();
        }

        if (!addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (deployedAddr(partyId) != address(0)) {
            revert AlreadyDeployed();
        }

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
        // if the deployed address doesn't exist
        if (deployedAddr(partyId) == address(0)) {
            bytes4 deployFunId = this.deploy.selector;
            // verify if functionId matches deployer's
            if (deployFunId != funId) {
                // reverts otherwise
                revert InvalidDeployFunId(funId);
            }
            // if the deployed address exists
        } else {
            // verify if the partyId contract voted already
            if (_contractOf(partyId).getLastEpoch() == currentEpoch()) {
                // reverts if it did
                revert AlreadyUpgraded();
            }
        }

        if (_voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }

        if (!addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (!addrIsIndexed(partyId, index, msg.sender)) {
            revert InvalidCallerWithIndex();
        }

        _vote(partyId, funId, index);
    }

    function propose(
        bytes32 partyId,
        IStories.ProposalType proposalType,
        address member,
        string memory newName
    ) public {
        INFT nftContract = INFT(deployedAddr(partyId));

        bytes4 funId;
        if (IStories.ProposalType.Name == proposalType) {
            funId = nftContract.proposeName.selector;
        } else if (IStories.ProposalType.Symbol == proposalType) {
            funId = nftContract.proposeSymbol.selector;
        } else if (IStories.ProposalType.URI == proposalType) {
            funId = nftContract.proposeURI.selector;
        } else {
            revert InvalidProposalType();
        }

        if (voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }

        if (
            address(nftContract) != msg.sender ||
            !addrIsOperator(partyId, msg.sender)
        ) {
            revert InvalidCaller();
        }
    }

    function proposeName(
        bytes32 partyId,
        address member,
        string memory newName
    ) public {
        address nftContract = deployedAddr(partyId);
        bytes4 funId = INFT(nftContract).proposeName.selector;

        _validateProposal(partyId, funId, nftContract);

        _proposeStories(partyId, getCurrentEpoch(), newName, "", "");
    }

    function proposeSymbol(
        bytes32 partyId,
        address member,
        string memory newSymbol
    ) public {
        address nftContract = deployedAddr(partyId);
        bytes4 funId = INFT(nftContract).proposeSymbol.selector;

        _validateProposal(partyId, funId, nftContract);

        _proposeStories(partyId, getCurrentEpoch(), "", newSymbol, "");
    }

    function proposeURI(bytes32 partyId, string memory newURI) public {
        IStories.ProposalType proposalType;
        address nftContract = deployedAddr(partyId);
        bytes4 funId = INFT(nftContract).proposeURI.selector;
        _validateProposal(partyId, funId, nftContract);

        _proposeStories(partyId, getCurrentEpoch(), "", "", newURI);
    }

    function _validateProposal(
        bytes32 partyId,
        bytes4 funId,
        address nftContract
    ) internal view {
        if (msg.sender != nftContract || !addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (voteIsAccepted(partyId, funId)) {
            revert AlreadyAccepted();
        }
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

    function isDeployed(bytes32 partyId) public view returns (bool) {
        return deployedAddr(partyId) != address(0);
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
