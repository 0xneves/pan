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
error NotDeployedYet();
error NotEnoughVotes();
error NotEveryoneVoted();

contract Controller is IController, IERC165, Governance, Deployer, Epoch {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) public {
        if (!votePassed(partyId, this.deploy.selector)) {
            revert NotEnoughVotes();
        }

        if (!addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (isDeployed(partyId)) {
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
        // we assume the party is voting for a deployment
        if (!isDeployed(partyId)) {
            bytes4 deployFunId = this.deploy.selector;
            // make sure that functionId matches deployer's
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

    function resetVotes(bytes32 partyId) public {
        if (address(_contractOf(partyId)) != msg.sender) {
            revert InvalidCaller();
        }

        bytes4[] memory funId = new bytes4[](4);
        funId[0] = NFT.upgrade.selector;
        funId[1] = NFT.proposeName.selector;
        funId[2] = NFT.proposeSymbol.selector;
        funId[3] = NFT.proposeURI.selector;

        _resetVotes(partyId, funId);
    }

    function propose(
        bytes32 partyId,
        IStories.ProposalType proposalType,
        address member,
        string memory data
    ) public {
        if (_deployedAddr(partyId) == address(0)) {
            revert NotDeployedYet();
        }

        INFT nftContract = _contractOf(partyId);

        // if the nft contract is the `msg.sender`,then the `member`
        // var should be trusted if validated as the operator.
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

        if (votePassed(partyId, funId)) {
            revert AlreadyAccepted();
        }
    }

    function getHealth(bytes32 partyId) public view returns (uint256) {
        return _contractOf(partyId).getHealth();
    }

    function getMissingHealth(bytes32 partyId) public view returns (uint256) {
        return _contractOf(partyId).getMissingHealth();
    }

    function getCurrentEpoch() public view returns (uint256) {
        return _currentEpoch();
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
