// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {BetterDeployer} from "../src/BetterDeployer.sol";
import {Carrot} from "./Veggies.sol";

contract BetterDeployerTest is Test {
    function testBetterDeployerMustDumpDeploymentsCorrectly() public {
        string memory deployFolder = "deployments";
        string memory deployFile = "myDeployments.json";

        BetterDeployer deployer1 = new BetterDeployer();
        deployer1.setPathAndFile(deployFolder, deployFile);
        Carrot carrot = Carrot(
            deployer1.deploy("mycarrot", "Veggies.sol:Carrot", "")
        );
        Carrot anotherCarrot = Carrot(
            deployer1.deploy("theircarrot", "Veggies.sol:Carrot", "")
        );
        deployer1.dump();
        assertTrue(vm.isFile(deployer1.deployFilePath()));
        BetterDeployer deployer2 = new BetterDeployer();
        deployer2.setPathAndFile(deployFolder, deployFile);

        address carrot1 = deployer2.getDeployment("mycarrot");
        assertEq(carrot1, address(carrot));

        vm.expectRevert();
        address nonexistent = deployer2.getDeployment("mycarrot1");
    }

    function testBetterDeployerNoFile() public {
        console2.log("current time", vm.unixTime());
        //string memory deployFolder = "deployments";
        //string memory deployFile = "";

        //BetterDeployer deployer1 = new BetterDeployer(deployFolder, deployFile);
        //Carrot carrot = Carrot(
        //    deployer1.deploy("mycarrot", "Veggies.sol:Carrot", "")
        //);
        //deployer1.dump();
    }
}
