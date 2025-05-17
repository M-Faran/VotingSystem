// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VotingSystem.sol";

// Deploy the VotingSystem contract
contract DeployVotingSystem is Script {
    function run() external {
        vm.startBroadcast();

        VotingSystem votingSystem = new VotingSystem();

        console.log("VotingSystem deployed at:", address(votingSystem));

        vm.stopBroadcast();
    }
}
