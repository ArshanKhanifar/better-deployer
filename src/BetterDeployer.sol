// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {CommonBase} from "forge-std/Base.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

contract BetterDeployer is CommonBase {
    using Strings for uint256;
    string public deploymentsPath = "";
    string public deploymentFile = "";
    string public constant BETTER_DEPLOYER_BANNER = "BetterDeployer: ";
    bool skipFile = false;

    function _log(string memory message) private pure returns (string memory) {
        return string.concat(BETTER_DEPLOYER_BANNER, message);
    }

    function setSkipFile(bool _skipFile) public {
        skipFile = _skipFile;
    }

    mapping(string => address) public addressBook;
    string[] public deployments;
    string fileContent = "";

    function setPathAndFile(
        string memory _path,
        string memory _deploymentFile
    ) public {
        setDeploymentsPath(_path);
        setDeploymentsFile(_deploymentFile);
    }

    function setDeploymentsPath(string memory _path) public {
        deploymentsPath = _path;
    }

    function setDeploymentsFile(string memory _deploymentFile) public {
        deploymentFile = (bytes(_deploymentFile).length == 0)
            ? getDefaultName()
            : _deploymentFile;
    }

    function ensureFileContentLoaded() public {
        if (bytes(fileContent).length > 0 || skipFile) {
            return;
        }
        string memory path = deployFilePath();
        if (vm.isFile(path)) {
            fileContent = vm.readFile(path);
        }
        string[] memory keys = vm.parseJsonKeys(fileContent, ".");
        for (uint256 i = 0; i < keys.length; i++) {
            string memory key = keys[i];
            loadFromFile(key);
        }
    }

    function loadFromFile(
        string memory name
    ) public returns (address deployment) {
        ensureFileContentLoaded();
        if (bytes(fileContent).length == 0) {
            return address(0);
        }
        return readKey(name);
    }

    function readKey(string memory key) private returns (address deployment) {
        try vm.parseJsonAddress(fileContent, string.concat(".", key)) returns (
            address dep
        ) {
            deployment = dep;
            recordAddress(key, deployment);
        } catch {
            deployment = address(0);
        }
    }

    function getDefaultName() public returns (string memory) {
        uint256 currTime = vm.unixTime();
        string memory timestamp = currTime.toString();
        return string.concat(timestamp, "_deployments.json");
    }

    function getDeployment(
        string memory deploymentName
    ) public returns (address deployed) {
        deployed = addressBook[deploymentName];
        if (deployed == address(0)) {
            deployed = loadFromFile(deploymentName);
        }
        if (deployed == address(0)) {
            revert(
                _log(
                    string.concat(
                        "No deployment found for ",
                        deploymentName,
                        "in file: ",
                        deployFilePath()
                    )
                )
            );
        }
    }

    function recordAddress(
        string memory deploymentName,
        address deployed
    ) public {
        vm.label(deployed, deploymentName);
        addressBook[deploymentName] = deployed;
        deployments.push(deploymentName);
    }

    function deploy(
        string memory deploymentName,
        string memory artifact,
        bytes memory args
    ) public returns (address deployed) {
        ensureFileContentLoaded();
        bytes memory bytecode = vm.getCode(artifact);
        bytes memory data = bytes.concat(bytecode, args);
        assembly {
            deployed := create(0, add(data, 0x20), mload(data))
        }
        if (deployed == address(0)) {
            revert(_log(string.concat("Failed to deploy ", deploymentName)));
        }
        recordAddress(deploymentName, deployed);
    }

    function deployFilePath() public view returns (string memory) {
        if (
            bytes(deploymentFile).length == 0 ||
            bytes(deploymentFile).length == 0
        ) {
            revert(_log("deployment file not set"));
        }
        return string.concat(deploymentsPath, "/", deploymentFile);
    }

    function backupFilePath() public returns (string memory) {
        return
            string.concat(
                deploymentsPath,
                "/",
                vm.unixTime().toString(),
                "_",
                deploymentFile
            );
    }

    function dump() public {
        if (skipFile) {
            return;
        }
        string memory file = "addressBook";
        for (uint i = 0; i < deployments.length - 1; i++) {
            string memory key = deployments[i];
            vm.serializeAddress(file, key, addressBook[key]);
        }
        string memory lastKey = deployments[deployments.length - 1];
        string memory collected = vm.serializeAddress(
            file,
            string(lastKey),
            addressBook[lastKey]
        );

        vm.writeJson(collected, deployFilePath());
        vm.writeJson(collected, backupFilePath());
    }
}
