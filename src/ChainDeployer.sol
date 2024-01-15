// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BetterDeployer} from "./BetterDeployer.sol";
import {BaseChainSetup} from "queso/BaseChainSetup.sol";

/// @title ChainDeployer
/// @notice Same as better deployer but with multi-chain setups.
contract ChainDeployer is BetterDeployer, BaseChainSetup {
    /// @notice gets the name of a deployment, prepended with chain alias
    /// @param chain the chain alias
    /// @param deploymentName the name of the deployment
    /// @return the name of the deployment prepended with the chain alias
    function _name(string memory chain, string memory deploymentName) private returns (string memory) {
        return string.concat(chain, "_", deploymentName);
    }

    /// @notice deploys a contract to a chain, switching to the chain first
    /// @param chain the chain alias
    /// @param deploymentName the name of the deployment
    /// @param artifact the artifact name
    /// @param args the constructor arguments
    function deployChain(string memory chain, string memory deploymentName, string memory artifact, bytes memory args)
        public
        returns (address deployed)
    {
        switchTo(chain);
        return deploy(_name(chain, deploymentName), artifact, args);
    }

    /// @notice gets the address of a deployment on a chain, switching to the chain first
    /// @param chain the chain alias
    /// @param deploymentName the name of the deployment
    /// @return the address of the deployment
    function getDeployment(string memory chain, string memory deploymentName) public returns (address) {
        return getDeployment(_name(chain, deploymentName));
    }
}
