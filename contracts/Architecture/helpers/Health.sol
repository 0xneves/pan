// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Health {
    uint256 health;

    function _missingHealth(
        uint256 lastEpoch,
        uint256 currEpoch
    ) internal pure returns (uint256) {
        // If action was not yet taken in this epoch
        if (lastEpoch < currEpoch) {
            // We give one credit if the
            // last epoch was not completed
            uint256 mhp = currEpoch - lastEpoch - 1;
            if (mhp > 0) {
                return mhp;
            }
        }
        // Otherwise action was taken in this epoch
        return 0;
    }

    function _virtualHealth() internal view returns (uint256) {}

    function _getHealth() public view returns (uint256) {
        return health;
    }
}
