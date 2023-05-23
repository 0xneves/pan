// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IsContract {
    function owner() external view returns (address);
}

contract MultiSign {
    mapping(address => mapping(bytes32 => bool)) private belong;
    mapping(bytes32 => address[]) private partners;

    function create(address[] memory addrs) public returns (bytes32) {
        bytes32 id = keccak256(
            abi.encodePacked(addrs, block.timestamp, address(this))
        );

        partners[id] = addrs;

        return id;
    }

    function join(bytes32 proof) public {
        address[] memory addrs = partners[proof];

        for (uint256 i; i < addrs.length; i++) {
            if (
                msg.sender == IsContract(addrs[i]).owner() ||
                msg.sender == addrs[i]
            ) {
                belong[msg.sender][proof] = true;
            } else {
                revert("Is not an EOA or contract owner");
            }
        }
    }

    function joinWithIndex(bytes32 proof, uint256 index) public {
        // lacks contract validation
        if (msg.sender == partners[proof][index]) {
            belong[msg.sender][proof] = true;
        }
    }

    function addressBelongs(
        address addr,
        bytes32 proof
    ) public view returns (bool) {
        return belong[addr][proof];
    }

    function partnersOf(bytes32 proof) public view returns (address[] memory) {
        return partners[proof];
    }
}
