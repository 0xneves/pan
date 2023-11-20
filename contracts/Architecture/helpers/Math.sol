// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Math {
    function genPartyId(
        address[] memory addrs,
        address governance
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(addrs, block.timestamp, governance));
    }

    function _hasVoted(
        uint256 sum,
        uint256 targetIndex
    ) internal pure returns (bool) {
        uint256 index = 0;

        while (sum > 0) {
            if (sum % 2 == 1) {
                if (index == targetIndex) {
                    return true;
                }
            }

            index++;
            sum = sum / 2;
        }

        return false;
    }

    function decompose(uint256 sum) public pure returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](256);
        uint256 index = 0;
        uint256 indexSizeResult = 0;

        while (sum > 0) {
            if (sum % 2 == 1) {
                ids[index] = 2 ** index;
                indexSizeResult++;
            }

            index++;
            sum = sum / 2;
        }

        uint256 indexResult = 0;
        uint256[] memory result = new uint256[](indexSizeResult);
        for (uint256 j = 0; j < index; j++) {
            if (ids[j] != 0) {
                result[indexResult] = _log2(ids[j]);
                indexResult++;
            }
        }

        return result;
    }

    function _log2(uint256 value) internal pure returns (uint256) {
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
}
