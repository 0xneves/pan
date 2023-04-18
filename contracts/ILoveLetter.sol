// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ILoveLetter {
    struct Partners {
        address l;
        address ll;
        uint256 hp;
    }

    event Bounded(address indexed l, address indexed ll);
}
