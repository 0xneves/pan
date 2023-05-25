// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./interfaces/INFT.sol";
import "./helpers/Health.sol";

import "./interfaces/IController.sol";
import "./interfaces/IGovernance.sol";
import "./interfaces/IStories.sol";

error ALIVE();
error DEAD();
error AlreadyVoted();
error InvalidCaller();
error NotEveryoneVoted();

contract NFT is INFT, IERC165, ERC721, Health {
    IController public CONTROLLER;
    IGovernance public GOVERNANCE;

    string public URI;
    string public NAME;
    string public SYMBOL;

    bytes32 public PARTY_ID;
    uint256 private LAST_EPOCH;
    uint256 private TOTAL_MEMBERS;

    constructor(
        bytes32 _partyId,
        address _controller,
        uint256 _totalMembers,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC721(_name, _symbol) {
        PARTY_ID = _partyId;
        URI = _uri;
        TOTAL_MEMBERS = _totalMembers;
        CONTROLLER = IController(_controller);
    }

    function name() public view virtual override returns (string memory) {
        return NAME;
    }

    function symbol() public view virtual override returns (string memory) {
        return SYMBOL;
    }

    function upgrade() public payable {
        // After everybody voted, it can be called again to upgrade
        // by anybody on the party. This means that this contract will
        // upgrade the NFT if everybody voted.

        // Check if NFT is alive
        if (getHealth() == 0) {
            revert DEAD();
        }

        // Governance - Must validate if user is in group
        if (GOVERNANCE.addrIsOperator(PARTY_ID, msg.sender)) {
            revert InvalidCaller();
        }

        // Governance - Must validate everybody voted already
        if (GOVERNANCE.votePassed(PARTY_ID, this.upgrade.selector)) {
            revert NotEveryoneVoted();
        }

        // Check if NFT was upgraded in this epoch
        if (CONTROLLER.getCurrentEpoch() == getLastEpoch()) {
            revert AlreadyVoted();
        }


        // Governance - Must set votes uint256 to 0
        CONTROLLER.resetVotes(PARTY_ID);

        // Update Last Epoch at the end
        LAST_EPOCH = CONTROLLER.getCurrentEpoch();

        // This - emit events
    }

    function kill() public {
        if (getHealth() != 0) {
            revert ALIVE();
        }

        _burn(1);

        payable(msg.sender).transfer(address(this).balance);
    }

    function proposeName(string memory newName) public {
        CONTROLLER.propose(
            PARTY_ID,
            IStories.ProposalType.Name,
            msg.sender,
            newName
        );
    }

    function proposeSymbol(string memory newSymbol) public {
        CONTROLLER.propose(
            PARTY_ID,
            IStories.ProposalType.Symbol,
            msg.sender,
            newSymbol
        );
    }

    function proposeURI(string memory newURI) public {
        CONTROLLER.propose(
            PARTY_ID,
            IStories.ProposalType.URI,
            msg.sender,
            newURI
        );
    }

    function getHealth() public view returns (uint256) {
        return _getHealth(LAST_EPOCH, CONTROLLER.getCurrentEpoch());
    }

    function getMissingHealth() public view returns (uint256) {
        return _missingHealth(LAST_EPOCH, CONTROLLER.getCurrentEpoch());
    }

    function getLastEpoch() public view returns (uint256) {
        return LAST_EPOCH;
    }

    function getTotalMembers() public view returns (uint256) {
        return TOTAL_MEMBERS;
    }

    function getAddrIndex(address addr) public view returns (uint256) {
        return GOVERNANCE.getAddrIndex(PARTY_ID, addr);
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public pure override(IERC165, ERC721, INFT) returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(INFT).interfaceId;
    }
}
