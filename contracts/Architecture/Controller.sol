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
error InvalidDeployFunId();
error InvalidLengthsProvided();
error InvalidProposalType();
error NotDeployedYet();
error NotEnoughVotes();

contract Controller is IController, IERC165, Governance, Deployer, Epoch {
    function deploy(
        bytes32 partyId,
        string memory name,
        string memory symbol,
        string memory uri
    ) public {
        if (!votePassed(partyId)) {
            revert NotEnoughVotes();
        }

        if (!addrIsOperator(partyId, msg.sender)) {
            revert InvalidCaller();
        }

        if (isDeployed(partyId)) {
            revert AlreadyDeployed();
        }

        if (
            bytes(name).length == 0 ||
            bytes(name).length > 100 ||
            bytes(symbol).length == 0 ||
            bytes(symbol).length > 7 ||
            bytes(uri).length == 0
        ) {
            revert InvalidLengthsProvided();
        }

        _resetVotes(partyId);

        _deploy(
            partyId,
            address(this),
            getTotalMembersOf(partyId),
            name,
            symbol,
            uri
        );
    }

    function vote(bytes32 partyId, uint256 index, address member) public {
        // if the NFT contract is deployed
        if (isDeployed(partyId)) {
            // verify if the NFT contract voted already
            if (_contractOf(partyId).getLastEpoch() == _currentEpoch()) {
                // reverts if it did
                revert AlreadyUpgraded();
            }
        }

        // if `member` is the caller, he should validate him as an operator
        if (member == msg.sender) {
            if (!addrIsOperator(partyId, member)) {
                revert InvalidCaller();
            }

            if (!addrIsIndexed(partyId, index, member)) {
                revert InvalidCallerWithIndex();
            }

            if (votePassed(partyId)) {
                revert AlreadyAccepted();
            }
        } else {
            // and if the NFT contract is the `caller` himself,
            // means he already validated the same things
            if (address(_contractOf(partyId)) != msg.sender) {
                revert InvalidCaller();
            }
        }

        _vote(partyId, index, _currentEpoch());
    }

    function resetVotes(bytes32 partyId) public {
        if (address(_contractOf(partyId)) != msg.sender) {
            revert InvalidCaller();
        }

        _resetVotes(partyId);
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
