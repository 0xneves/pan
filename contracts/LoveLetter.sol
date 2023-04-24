// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ILoveLetter.sol";

/** - v1.0.0
 * @title LoveLetter. An ownerless base contract that scores addresses
 *        interactions on-chain through NFTs.
 * @author @0xneves
 * @notice This is a singular and elegant present for the girl of my dreams...
 */
contract LoveLetter is ERC721, ILoveLetter, IERC721Receiver {
    string uri =
        "https://gateway.pinata.cloud/ipfs/QmQa3conern34JY4YGkW6BkjuN3VvyLNkwnFVhpJ32VxEg";
    Partners public us;
    Votes votes;

    mapping(bytes32 => string) public stories;

    uint256 public DAY = 24 * 60 * 60;
    uint256 public MONTH = 31 * DAY;
    uint256 public QUARTER = 3 * MONTH;
    uint256 public CLOCK;

    constructor(
        address _l,
        address _ll
    ) payable ERC721("I Love You", "LOVERS") {
        CLOCK = block.timestamp;

        us.l = _l;
        us.ll = _ll;
        us.hp = 1;
        us.record = currentEpoch();

        _safeMint(address(this), 1);
        emit Bounded(_l, _ll);
    }

    function updateRelation(string memory _msg) public {
        require(virtualHp() > 0, "Game Over.");
        require(
            us.record < currentEpoch(),
            "You already intaracted in this quarter"
        );

        if (missingHp() > 0) {
            us.hp -= missingHp();
        }

        if (msg.sender == us.l && votes.l != virtualEpoch()) {
            votes.l = virtualEpoch();
        } // votes for l

        if (msg.sender == us.ll && votes.ll != virtualEpoch()) {
            votes.ll = virtualEpoch();
        } // votes for ll

        if (votes.l == virtualEpoch() && votes.ll == virtualEpoch()) {
            us.record = currentEpoch();
            us.hp += 1;
            if (abi.encodePacked(_msg).length > 0) {
                stories[hashproof()] = _msg;
            }
        } // validates the epoch

        emit Validated(block.timestamp);
    }

    function missingHp() public view returns (uint256) {
        // If action was not yet taken in this epoch
        if (us.record < currentEpoch()) {
            // We give one credit if the
            // last epoch was not completed
            uint256 mhp = currentEpoch() - us.record - 1;
            if (mhp > 0) {
                return mhp;
            }
        }
        // Otherwise action was taken in this epoch
        return 0;
    }

    function virtualHp() public view returns (uint256) {
        int t = int(us.hp) - int(missingHp());
        if (t > 0) {
            return uint256(t);
        } else {
            return 0;
        }
    }

    function currentEpoch() public view returns (uint256) {
        return (timeSince() / QUARTER) + 1;
    }

    function virtualEpoch() public view returns (uint256) {
        return currentEpoch() + 1;
    }

    function timeSince() public view returns (uint256) {
        return (block.timestamp - CLOCK);
    }

    function hashproof() public view returns (bytes32) {
        return keccak256(abi.encodePacked(us.l, us.ll, block.timestamp));
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function burnRelation() public {
        require(
            virtualHp() == 0,
            "LoveLetter: Only relations with no health can cease to exist."
        );

        _burn(1);
        emit Burn(us.l, us.ll, us.record);

        payable(msg.sender).transfer(address(this).balance);
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
