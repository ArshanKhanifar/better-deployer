// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BetterDeployer} from "./BetterDeployer.sol";
import {BaseChainSetup} from "arshans-forge-toolkit/BaseChainSetup.sol";

contract ChainDeployer is BetterDeployer, BaseChainSetup {
    function deployChain(
        string memory chain,
        string memory deploymentName,
        string memory artifact,
        bytes memory args
    ) public returns (address deployed) {
        switchTo(chain);
        return deploy(string.concat(chain, deploymentName), artifact, args);
    }
}
