// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MultiSign.sol";

contract Vote {
    MultiSign MULTISIGN;

    constructor(address addr) {
        MULTISIGN = MultiSign(addr);
    }

    // mapping(bytes32 => uint256) private votes;
    mapping(bytes32 => uint256) private votes;

    function vote(bytes32 proof, uint256 index) public {
        if (!myIndexForSure(proof, index)) {
            revert("not you mate");
        }

        if (MULTISIGN.addressBelongs(msg.sender, proof)) {
            uint256[] memory d = decompose(votes[proof]);

            for (uint i = 0; i < d.length; i++) {
                if (index == d[i]) {
                    revert("Already voted");
                }
            }

            votes[proof] += 2 ** index;
        } else {
            revert("Not in the group");
        }
    }

    function decompose(uint256 nftSum) public pure returns (uint256[] memory) {
        uint256[] memory nftIds = new uint256[](256);
        uint256 index = 0;
        uint256 indexSizeResult = 0;

        while (nftSum > 0) {
            if (nftSum % 2 == 1) {
                nftIds[index] = 2 ** index;
                indexSizeResult++;
            }

            index++;
            nftSum = nftSum / 2;
        }

        uint256 indexResult = 0;
        uint256[] memory result = new uint256[](indexSizeResult);
        for (uint256 j = 0; j < index; j++) {
            if (nftIds[j] != 0) {
                result[indexResult] = log2(nftIds[j]);
                indexResult++;
            }
        }

        return result;
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function myIndexForSure(
        bytes32 proof,
        uint256 index
    ) public view returns (bool) {
        address[] memory partners = MULTISIGN.partnersOf(proof);
        return msg.sender == partners[index];
    }

    function myIndex(bytes32 proof) public view returns (uint256) {
        address[] memory partners = MULTISIGN.partnersOf(proof);

        for (uint256 i = 0; i < partners.length; i++) {
            if (msg.sender == partners[i]) {
                return i;
            }
        }

        revert("Not in the index");
    }
}
