// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BetterDeployer} from "./BetterDeployer.sol";
import {BaseChainSetup} from "arshans-forge-toolkit/BaseChainSetup.sol";

contract ChainDeployer is BetterDeployer, BaseChainSetup {
    function _name(
        string memory chain,
        string memory deploymentName
    ) private returns (string memory) {
        return string.concat(chain, "_", deploymentName);
    }

    function deployChain(
        string memory chain,
        string memory deploymentName,
        string memory artifact,
        bytes memory args
    ) public returns (address deployed) {
        switchTo(chain);
        return deploy(_name(chain, deploymentName), artifact, args);
    }

    function getDeployment(
        string memory chain,
        string memory deploymentName
    ) public returns (address) {
        return getDeployment(_name(chain, deploymentName));
    }
}
