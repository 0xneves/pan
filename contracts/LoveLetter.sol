// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ILoveLetter.sol";
import "hardhat/console.sol";

/**
 * @title LoveLetter. A base contract to score relationship through NFTs.
 * @author @dizzyexistence
 * @notice This is a singular and elegant present for the girl of my dreams.
 */
contract LoveLetter is ERC721, ILoveLetter, IERC721Receiver {
    string uri = "IPFS_URI";
    mapping(uint256 => Partners) public life;

    constructor(
        address _l,
        address _ll
    ) payable ERC721("I Love You", "LOVERS") {
        life[0].l = _l;
        life[0].ll = _ll;
        life[0].hp = 1;

        _safeMint(address(this), 1);
        emit Bounded(_l, _ll);
    }

    function getPartnersData() public view returns (Partners memory) {
        return life[0];
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /* Receive ETH */
    receive() external payable {}
}
