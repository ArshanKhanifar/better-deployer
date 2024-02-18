![docs](https://github.com/arshankhanifar/better-deployer/actions/workflows/mdbook.yml/badge.svg)

# Better Deployer

Better deployer is a set of simple libraries that help with
simplification of contract deployments. It allows for:

1. Unifying the deployment of contracts across tests and scripts.
2. Naming each deployment, and using `vm.label` under the hood
   so that they show up in the chain logs when you run foundry scripts
   or tests with `-vvvv` verbosity.
3. Saving all the deployments to a file, in case of a script, so that
   the file can easily be copy/pasted into another UI project. It also
   timestamps each run so nothing is lost.
4. Loading already-deployed addresses into scripts easily.

## How it works

### Without Better Deployer

Normally when you have a contract, in your tests you'd do something like

```
Cat cat = new Cat();
cat.meow();
```

then in your deploy scripts you'd do something like:

```
Cat cat = new Cat();
dumpToFile(address(cat));
```

then in another script when you want to interact with that contract you'd
do something like:

```
Cat cat = Cat(loadAddressFromFile());
cat.meow();
```

You would have to implement the `dumpToFile` and `loadAddressFromFile` manually.
You'd have to make sure files aren't overridden so old addresses aren't lost.
Working with files/JSON files in solidity using foundry's cheatcodes aren't easy either.

### With Better Deployer

But now, you can do something like so:

```
string memory deployFolder = "deployments";
string memory deployFile = "myDeployments.json";

BetterDeployer deployer1 = new BetterDeployer();
deployer1.setPathAndFile(deployFolder, deployFile);
Carrot carrot = Carrot(
    deployer1.deploy("mycarrot", "Veggies.sol:Carrot", "")
);
deployer1.dump(); // dumps to file
```

after you run the script, it will generate a file in `deployments/myDeployments.json`,
with the name of the deployed contract and its address in there.

Later you can load the contract like so:

```
string memory deployFolder = "deployments";
string memory deployFile = "myDeployments.json";

BetterDeployer deployer1 = new BetterDeployer();
deployer1.setPathAndFile(deployFolder, deployFile);
Carrot carrot = Carrot(
    deployer1.getDeployment("mycarrot")
);
```

# API
## `BetterDeployer.sol`

### `setPathAndFile`

```
    function setPathAndFile(
        string memory _path,
        string memory _deploymentFile
    )
```

Call this function to specify what file to dump to.

### `setPathAndFile`

Dumps to the file.

### `function setSkipFile(bool _skipFile)`

Skips dumping to the file. This is used usually in the
`setUp` function of your tests, so running unit-tests
does not generate an address.

### `function getDeployment( string memory deploymentName )`

Gets the deployment by name, stored in the file previously set.

## `ChainDeployer.sol`
Extends `BetterDeployer` for when you want to deploy to
different chains. All it does is that it prefixes the 
names with `<chain>_<deploymentName>`.

An example of what this looks like is in the UTB contracts:
``` 
// in forknet_deployments.json
  "arbitrum_UniSwapper": "0xE3e5D4b00c96bc94353d4F48305C42e695A50e86",
  "arbitrum_utbExecutor": "0x1590031e710B6613598a71Fed598562Bfd012C9F",
  "base_DcntEth": "0xD058C88FA412f1a2Fc53844b280e4b0C075c6F10",
  "base_DecentBridgeAdapter": "0x0f34b97c3F0763be7a0522AB901e6eB4Fd355e60",
```

