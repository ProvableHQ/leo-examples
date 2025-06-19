# Upgrading Your Leo Programs

[ARC-0006](https://github.com/ProvableHQ/ARCs/discussions/94) proposes a number of changes to the AVM, which enable program upgradability.
Different blockchain ecosystems take approaches to upgradability, with varying degrees of complexity, expressiveness, and security.
The AVM is one point in this design space and Leo aims to provide a users with clean interface to develop and deploy programs, and to upgrade them in the future.

## Resources for Program Upgradability

- [ARC-0006](https://github.com/ProvableHQ/ARCs/discussions/94)
- [snarkVM tracker](https://github.com/ProvableHQ/snarkVM/issues/2654)
- [snarkOS PR](https://github.com/ProvableHQ/snarkOS/pull/3638)
- [Leo PR](https://github.com/ProvableHQ/leo/pull/28593)

The implementations for snarkVM, snarkOS, and Leo are all still in development.
To start using these features, we'll need to set up a custom development environment.

## Setting up snarkOS

You will first need to clone the snarkOS repository and checkout a working commit.
``` 
> git clone https://github.com/ProvableHQ/snarkOS.git
> cd snarkOS
> git checkout f5838916
```

You can then install and run a local development network with the following command and presets:
**Note: you need be in the snarkOS directory.**
``` 
> chmod +x devnet.sh
> ./devnet.sh
Enter the total number of validators (default: 4): 4
Enter the total number of clients (default: 2): 0
Enter the network ID (mainnet = 0, testnet = 1, canary = 2) (default: 1): 1
Do you want to run 'cargo install --locked --path .' to build the binary? (y/n, default: y): y
Do you want to clear the existing ledger history? (y/n, default: n): y
Do you want to enable validator telemetry? (y/n, default: y): n
Enter crate features to enable (comma separated, default: none): test_network
Running build command: "cargo install --locked --path . --features test_network"
```

**Note: The devnet will need to produce a few blocks before it is ready to accept upgradable programs.**
You can verify that it is ready by querying the REST endpoint and checking that the consensus version is 7 or greater.
```
http://localhost:3030/testnet/consensus_version
```


## Setting up Leo

You will need to clone the Leo repository and checkout a working commit.
```
> git clone https://github.com/ProvableHQ/leo.git
> cd leo
> git checkout 74ad797 
```
You may use ``

You can then install Leo with the following command:
```
> cargo install --locked --path . --features test_network
```

**Note: You will need to ensure that all of your Leo programs use `.env` file** that looks like this:
```
NETWORK=testnet
PRIVATE_KEY=APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH
ENDPOINT=http://localhost:3030
```
which will use a private key that is already funded and point to the local devnet.

## Trying Out Upgradable Programs

You can refer to one of the following tutorials to get started with upgradable programs:
- [Non-upgradable Programs](01_noupgrade.md)
- [Admin-based Upgrade](02_admin.md)
- [Timelocked Upgrade](03_timelock.md)
- [Vote-based Upgrade](04_vote.md)

