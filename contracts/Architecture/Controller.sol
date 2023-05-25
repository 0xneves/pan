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
error NoDeployYet();
error NotEnoughVotes();
error NotEveryoneVoted();

contract Controller is IController, IERC165, Governance, Deployer, Epoch {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) public {
        if (!_votePassed(partyId, this.deploy.selector)) {
            revert NotEnoughVotes();
        }

        if (!addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (_deployedAddr(partyId) != address(0)) {
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
        if (_deployedAddr(partyId) == address(0)) {
            bytes4 deployFunId = this.deploy.selector;
            // verify if functionId matches deployer's
            if (deployFunId != funId) {
                // reverts otherwise
                revert InvalidDeployFunId(funId);
            }
            // if the deployed address exists
        } else {
            // verify if the partyId contract voted already
            if (_contractOf(partyId).getLastEpoch() == _currentEpoch()) {
                // reverts if it did
                revert AlreadyUpgraded();
            }
        }

        if (votePassed(partyId, funId)) {
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
        string memory data
    ) public {
        if (_deployedAddr(partyId) == address(0)) {
            revert NoDeployYet();
        }

        INFT nftContract = INFT(_deployedAddr(partyId));

        // if the nft contract is the `msg.sender`,then the `member`
        // should be trusted if validated as the operator.
        if (address(nftContract) == msg.sender) {
            if (!addrIsOperator(partyId, member)) {
                revert InvalidCaller();
            }
            // if the `msg.sender` is not the nft contract, means
            // this function is being called on the Controller
            // itself. Therefore, the `msg.sender` should
            // be used instead of the `member`.
        } else if (!addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        // to validate this step we need to know which
        // proposalType was given by the caller. Then
        // retrieve the functionId of the proposalType.
        bytes4 funId;
        // if the proposalType is Name, then the functionId
        // should be the selector of the `proposeName`
        // function of the nft contract.
        if (IStories.ProposalType.Name == proposalType) {
            funId = nftContract.proposeName.selector;
            _proposeStories(partyId, _currentEpoch(), data, "", "");
        } else if (IStories.ProposalType.Symbol == proposalType) {
            funId = nftContract.proposeSymbol.selector;
            _proposeStories(partyId, _currentEpoch(), "", data, "");
        } else if (IStories.ProposalType.URI == proposalType) {
            funId = nftContract.proposeURI.selector;
            _proposeStories(partyId, _currentEpoch(), "", "", data);
        } else {
            revert InvalidProposalType();
        }

        if (_votePassed(partyId, funId)) {
            revert AlreadyAccepted();
        }
    }

    function _validateProposal(
        bytes32 partyId,
        bytes4 funId,
        address nftContract
    ) internal view {
        if (msg.sender != nftContract || !addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (votePassed(partyId, funId)) {
            revert AlreadyAccepted();
        }
    }

    function votePassed(
        bytes32 partyId,
        bytes4 funId
    ) public view returns (bool) {
        return _votePassed(partyId, funId);
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
        return _currentEpoch();
    }

    function getVirtualEpoch() public view returns (uint256) {
        return _virtualEpoch();
    }

    function getLifeSpan() public view returns (uint256) {
        return _lifespan();
    }

    function getDeployTime() public view returns (uint256) {
        return _deployTime();
    }

    function getDeployedAddr(bytes32 partyId) public view returns (address) {
        return _deployedAddr(partyId);
    }

    function isDeployed(bytes32 partyId) public view returns (bool) {
        return _deployedAddr(partyId) != address(0);
    }

    function _contractOf(bytes32 partyId) internal view returns (INFT) {
        return INFT(_deployedAddr(partyId));
    }

    function supportsInterface(
        bytes4 interfaceID
    ) external pure override(IERC165, IController) returns (bool) {
        return
            interfaceID == type(IERC165).interfaceId ||
            interfaceID == type(IController).interfaceId;
    }
}
