# ChainDeployer
[Git Source](https://github.com/ArshanKhanifar/better-deployer/blob/ae0fed9a313ccaa9c1e53fdb869ea41762aba386/src/ChainDeployer.sol)

**Inherits:**
[BetterDeployer](/src/BetterDeployer.sol/contract.BetterDeployer.md), BaseChainSetup

Same as better deployer but with multi-chain setups.


## Functions
### _name

gets the name of a deployment, prepended with chain alias


```solidity
function _name(string memory chain, string memory deploymentName) private returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chain`|`string`|the chain alias|
|`deploymentName`|`string`|the name of the deployment|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|the name of the deployment prepended with the chain alias|


### deployChain

deploys a contract to a chain, switching to the chain first


```solidity
function deployChain(string memory chain, string memory deploymentName, string memory artifact, bytes memory args)
    public
    returns (address deployed);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chain`|`string`|the chain alias|
|`deploymentName`|`string`|the name of the deployment|
|`artifact`|`string`|the artifact name|
|`args`|`bytes`|the constructor arguments|


### getDeployment

gets the address of a deployment on a chain, switching to the chain first


```solidity
function getDeployment(string memory chain, string memory deploymentName) public returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chain`|`string`|the chain alias|
|`deploymentName`|`string`|the name of the deployment|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the address of the deployment|


