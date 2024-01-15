# BetterDeployer
[Git Source](https://github.com/ArshanKhanifar/better-deployer/blob/ae0fed9a313ccaa9c1e53fdb869ea41762aba386/src/BetterDeployer.sol)

**Inherits:**
CommonBase

A contract that can deploy other contracts and keep track of them


## State Variables
### deploymentsPath
The path to the directory where the deployment files are stored


```solidity
string public deploymentsPath = "";
```


### deploymentFile
The name of the deployment file


```solidity
string public deploymentFile = "";
```


### BETTER_DEPLOYER_BANNER
The banner to prepend to all log messages


```solidity
string public constant BETTER_DEPLOYER_BANNER = "BetterDeployer: ";
```


### skipFile
Whether to skip the deployment file, useful for unit tests


```solidity
bool skipFile = false;
```


### addressBook
mapping of deployment names to addresses


```solidity
mapping(string => address) public addressBook;
```


### deployments
list of deployment names


```solidity
string[] public deployments;
```


### fileContent
file content of the loaded deployment file


```solidity
string fileContent = "";
```


## Functions
### _log

internal logging


```solidity
function _log(string memory message) private pure returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`string`|The message to log|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The message with the banner prepended|


### setSkipFile

utility function to set if the deployment file should be skipped to be generated


```solidity
function setSkipFile(bool _skipFile) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_skipFile`|`bool`|Whether to skip the deployment file|


### setPathAndFile

The constructor, sets the path and file name of the deployment file:
i.e.: "deployments", "mainnet_deployments.json" will result in a file at "deployments/mainnet_deployments.json"


```solidity
function setPathAndFile(string memory _path, string memory _deploymentFile) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_path`|`string`|The path to the directory where the deployment files are stored|
|`_deploymentFile`|`string`|The name of the deployment file|


### setDeploymentsPath

Sets the path to the directory where the deployment files are stored


```solidity
function setDeploymentsPath(string memory _path) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_path`|`string`|The path to the directory where the deployment files are stored|


### setDeploymentsFile

Sets the name of the deployment file


```solidity
function setDeploymentsFile(string memory _deploymentFile) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deploymentFile`|`string`|The name of the deployment file|


### ensureFileContentLoaded

loads the deployment file into memory, used to lazy load the file


```solidity
function ensureFileContentLoaded() public;
```

### loadFromFile

gets the address of a deployment from the deployment file, loading it if necessary


```solidity
function loadFromFile(string memory name) public returns (address deployment);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The name of the deployment|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`deployment`|`address`|The address of the deployment|


### readKey

reads a key from the deployment file


```solidity
function readKey(string memory key) private returns (address deployment);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`string`|The key to read|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`deployment`|`address`|The address of the deployment|


### getDefaultName

gets the default name of the deployment file


```solidity
function getDefaultName() public returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The default name of the deployment file|


### getDeployment

gets the address of a deployment from the deployment file, queried by its name


```solidity
function getDeployment(string memory deploymentName) public returns (address deployed);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`deploymentName`|`string`|The name of the deployment|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`deployed`|`address`|The address of the deployment|


### recordAddress

records the address of a deployment to the address book and the deployment list


```solidity
function recordAddress(string memory deploymentName, address deployed) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`deploymentName`|`string`|The name of the deployment|
|`deployed`|`address`|The address of the deployment|


### deploy

deploys a contract and records its address


```solidity
function deploy(string memory deploymentName, string memory artifact, bytes memory args)
    public
    returns (address deployed);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`deploymentName`|`string`|The name of the deployment|
|`artifact`|`string`|The name of the artifact to deploy|
|`args`|`bytes`|The arguments to pass to the constructor|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`deployed`|`address`|The address of the deployed contract|


### deployFilePath

the path to the deployment file, which is set by setPathAndFile


```solidity
function deployFilePath() public view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The path to the deployment file|


### backupFilePath

the path to the backup file, this is the same as the deployment file but with a timestamp prepended
to avoid overwriting the deployment file.


```solidity
function backupFilePath() public returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The path to the backup file|


### dump

dumps the address book to the deployment file as well as the backup file


```solidity
function dump() public;
```

