// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/INFT.sol";
import "./helpers/Health.sol";

contract NFT is ERC721, INFT, Health {
    string public URI;

    uint256 private lastInteraction;

    constructor(string memory _uri) ERC721("LifesPan", "PAN") {
        URI = _uri;
    }

    function getURI() public view returns (string memory) {
        return URI;
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
    }

    function kill() public {}

    function changeName() public {
        // bytes4 selector = INFT(address(this)).changeName.selector;
    }

    function changeBaseURI() public {}

    function hashproof(uint256 _record) internal view returns (bytes32) {}

    function _baseURI() internal view override returns (string memory) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, INFT) returns (bool) {}
}
