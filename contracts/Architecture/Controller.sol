// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Governance.sol";
import "./Deployer.sol";

import "./interfaces/INFT.sol";
import "./helpers/Epoch.sol";

contract Controller is Governance, Deployer, Epoch {
    uint256 private DEPLOY_TIME;

    constructor() {
        DEPLOY_TIME = block.timestamp;
    }

    function deployTime() public view returns (uint256) {
        return DEPLOY_TIME;
    }

    function isProtocolOwner(
        bytes32 partyId,
        address addr
    ) public view returns (bool) {
        // Party - PartnersOf to get the party members
        // This - Check if the addressBelongs
        // This - Return comparison result
    }

    function missingHealth(bytes32 partyId) public view returns (uint256) {
        return INFT(deployedAddr(partyId)).missingHealth();
    }

    function health(bytes32 partyId) public view returns (uint256) {
        return INFT(deployedAddr(partyId)).health();
    }

    function vote(bytes32 partyId, uint256 index) public {
        // Governance - Vote
        _vote(partyId, index, deployedAddr(partyId), currentEpoch());
    }
}
