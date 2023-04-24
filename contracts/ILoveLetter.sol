// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILoveLetter {
    struct Partners {
        address l;
        address ll;
        uint256 hp;
        uint256 record;
    }

    struct Votes {
        uint256 l;
        uint256 ll;
    }

    event Bounded(address indexed l, address indexed ll);

    event Burn(address indexed l, address indexed ll, uint256 indexed epoch);

    event Validated(uint256 indexed timestamp);
}
