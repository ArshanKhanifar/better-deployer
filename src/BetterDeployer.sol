// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {CommonBase} from "forge-std/Base.sol";
import {LibString} from "solady/utils/LibString.sol";

/// @title BetterDeployer
/// @notice A contract that can deploy other contracts and keep track of them
contract BetterDeployer is CommonBase {
    using LibString for uint256;

    /// @notice The path to the directory where the deployment files are stored
    string public deploymentsPath = "";
    /// @notice The name of the deployment file
    string public deploymentFile = "";
    /// @notice The banner to prepend to all log messages
    string public constant BETTER_DEPLOYER_BANNER = "BetterDeployer: ";
    /// @notice Whether to skip the deployment file, useful for unit tests
    bool skipFile = false;

    /// @notice internal logging
    /// @param message The message to log
    /// @return The message with the banner prepended
    function _log(string memory message) private pure returns (string memory) {
        return string.concat(BETTER_DEPLOYER_BANNER, message);
    }

    /// @notice utility function to set if the deployment file should be skipped to be generated
    /// @param _skipFile Whether to skip the deployment file
    function setSkipFile(bool _skipFile) public {
        skipFile = _skipFile;
    }

    /// @notice mapping of deployment names to addresses
    mapping(string => address) public addressBook;
    /// @notice list of deployment names
    string[] public deployments;
    /// @notice file content of the loaded deployment file
    string fileContent = "";

    /// @notice The constructor, sets the path and file name of the deployment file:
    /// i.e.: "deployments", "mainnet_deployments.json" will result in a file at "deployments/mainnet_deployments.json"
    /// @param _path The path to the directory where the deployment files are stored
    /// @param _deploymentFile The name of the deployment file
    function setPathAndFile(string memory _path, string memory _deploymentFile) public {
        setDeploymentsPath(_path);
        setDeploymentsFile(_deploymentFile);
    }

    /// @notice Sets the path to the directory where the deployment files are stored
    /// @param _path The path to the directory where the deployment files are stored
    function setDeploymentsPath(string memory _path) public {
        deploymentsPath = _path;
    }

    /// @notice Sets the name of the deployment file
    /// @param _deploymentFile The name of the deployment file
    function setDeploymentsFile(string memory _deploymentFile) public {
        deploymentFile = (bytes(_deploymentFile).length == 0) ? getDefaultName() : _deploymentFile;
    }

    /// @notice loads the deployment file into memory, used to lazy load the file
    function ensureFileContentLoaded() public {
        if (bytes(fileContent).length > 0 || skipFile) {
            return;
        }
        string memory path = deployFilePath();
        if (vm.isFile(path)) {
            fileContent = vm.readFile(path);
        } else {
            fileContent = "{}";
        }
        string[] memory keys = vm.parseJsonKeys(fileContent, ".");
        for (uint256 i = 0; i < keys.length; i++) {
            string memory key = keys[i];
            loadFromFile(key);
        }
    }

    /// @notice gets the address of a deployment from the deployment file, loading it if necessary
    /// @param name The name of the deployment
    /// @return deployment The address of the deployment
    function loadFromFile(string memory name) public returns (address deployment) {
        ensureFileContentLoaded();
        if (bytes(fileContent).length == 0) {
            return address(0);
        }
        return readKey(name);
    }

    /// @notice reads a key from the deployment file
    /// @param key The key to read
    /// @return deployment The address of the deployment
    function readKey(string memory key) private returns (address deployment) {
        try vm.parseJsonAddress(fileContent, string.concat(".", key)) returns (address dep) {
            deployment = dep;
            recordAddress(key, deployment);
        } catch {
            deployment = address(0);
        }
    }

    /// @notice gets the default name of the deployment file
    /// @return The default name of the deployment file
    function getDefaultName() public returns (string memory) {
        uint256 currTime = vm.unixTime();
        string memory timestamp = currTime.toString();
        return string.concat(timestamp, "_deployments.json");
    }

    /// @notice gets the address of a deployment from the deployment file, queried by its name
    /// @param deploymentName The name of the deployment
    /// @return deployed The address of the deployment
    function getDeployment(string memory deploymentName) public returns (address deployed) {
        deployed = addressBook[deploymentName];
        if (deployed == address(0)) {
            deployed = loadFromFile(deploymentName);
        }
        if (deployed == address(0)) {
            revert(_log(string.concat("No deployment found for ", deploymentName, "in file: ", deployFilePath())));
        }
    }

    /// @notice records the address of a deployment to the address book and the deployment list
    /// @param deploymentName The name of the deployment
    /// @param deployed The address of the deployment
    function recordAddress(string memory deploymentName, address deployed) public {
        vm.label(deployed, deploymentName);
        addressBook[deploymentName] = deployed;
        deployments.push(deploymentName);
    }

    /// @notice deploys a contract and records its address, same as deploy(string, string, bytes) but
    /// with no constructor arguments.
    /// @param deploymentName The name of the deployment
    /// @param artifact The name of the artifact to deploy
    /// @return deployed The address of the deployed contract
    /// @dev this function is here to make it easier to deploy contracts
    function deploy(string memory deploymentName, string memory artifact) public returns (address deployed) {
        return deploy(deploymentName, artifact, "");
    }

    /// @notice deploys a contract and records its address
    /// @param deploymentName The name of the deployment
    /// @param artifact The name of the artifact to deploy
    /// @param args The arguments to pass to the constructor
    /// @return deployed The address of the deployed contract
    function deploy(string memory deploymentName, string memory artifact, bytes memory args)
        public
        returns (address deployed)
    {
        ensureFileContentLoaded();
        bytes memory bytecode = vm.getCode(artifact);
        bytes memory data = bytes.concat(bytecode, args);
        assembly ("memory-safe") {
            deployed := create(0, add(data, 0x20), mload(data))
        }
        if (deployed == address(0)) {
            revert(_log(string.concat("Failed to deploy ", deploymentName)));
        }
        recordAddress(deploymentName, deployed);
    }

    /// @notice the path to the deployment file, which is set by setPathAndFile
    /// @return The path to the deployment file
    function deployFilePath() public view returns (string memory) {
        if (bytes(deploymentFile).length == 0 || bytes(deploymentFile).length == 0) {
            revert(_log("deployment file not set"));
        }
        return string.concat(deploymentsPath, "/", deploymentFile);
    }

    /// @notice the path to the backup file, this is the same as the deployment file but with a timestamp prepended
    /// to avoid overwriting the deployment file.
    /// @return The path to the backup file
    function backupFilePath() public returns (string memory) {
        return string.concat(deploymentsPath, "/", vm.unixTime().toString(), "_", deploymentFile);
    }

    /// @notice dumps the address book to the deployment file as well as the backup file
    function dump() public {
        if (skipFile) {
            return;
        }
        string memory file = "addressBook";
        for (uint256 i = 0; i < deployments.length - 1; i++) {
            string memory key = deployments[i];
            vm.serializeAddress(file, key, addressBook[key]);
        }
        string memory lastKey = deployments[deployments.length - 1];
        string memory collected = vm.serializeAddress(file, string(lastKey), addressBook[lastKey]);

        vm.writeJson(collected, deployFilePath());
        vm.writeJson(collected, backupFilePath());
    }
}
