// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./interfaces/INFT.sol";
import "./helpers/Health.sol";

import "./interfaces/IController.sol";
import "./interfaces/IGovernance.sol";

error MustReachZeroHealthPoints();
error NotEnoughVotes();
error InvalidIndex();

contract NFT is INFT, IERC165, ERC721, Health {
    IController public CONTROLLER;
    IGovernance public GOVERNANCE;
    bytes32 public PARTY_ID;

    string public URI;
    string public NAME;
    string public SYMBOL;

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
        // This should be called once by all or vote directly
        // After everybody voted, it can be called again to upgrade
        // by anybody on the party. This means that this contract will
        // allow msg.sender to vote if he is in the party. Or it will
        // upgrade the NFT if everybody voted.
        //
        // This - Check if NFT is alive
        // This - Check if NFT was upgraded in this epoch
        //
        // Governance - Must validate if user is in group
        // Governance - Must validate everybody voted already
        //
        // This - Upgrade approved by governance
        // Governance - Must set votes uint256 to 0
        // Governance - Must check pending voting for name or uri change
        // This - Update name or uri if needed
        // This - Charge fee
        // This - Save story of each member
        // This - emit events

        // Update Last Epoch at the end
        LAST_EPOCH = CONTROLLER.getCurrentEpoch();
    }

    function proposeName(string memory newName, uint256 index) public {
        CONTROLLER.proposeName(PARTY_ID, index, msg.sender, newName);
    }

    function proposeSymbol(string memory newSymbol, uint256 index) public {
        CONTROLLER.proposeSymbol(PARTY_ID, index, msg.sender, newSymbol);
    }

    function proposeURI(string memory newURI, uint256 index) public {
        CONTROLLER.proposeURI(PARTY_ID, index, msg.sender, newURI);
    }

    function kill() public {
        if (getHealth() != 0) {
            revert MustReachZeroHealthPoints();
        }

        _burn(1);

        payable(msg.sender).transfer(address(this).balance);
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
