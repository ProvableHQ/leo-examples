# Upgrading Your Leo Programs

[ARC-0006](https://github.com/ProvableHQ/ARCs/discussions/94) proposes a number of changes to the AVM, which enable program upgradability.
Different blockchain ecosystems take approaches to upgradability, with varying degrees of complexity, expressiveness, and security.
The AVM is one point in this design space and Leo aims to provide a users with clean interface to develop and deploy programs, and to upgrade them in the future.

## Resources for Program Upgradability

- [ARC-0006](https://github.com/ProvableHQ/ARCs/discussions/94)
- [snarkVM tracker](https://github.com/ProvableHQ/snarkVM/issues/2654)
- [snarkOS PR](https://github.com/ProvableHQ/snarkOS/pull/3638)
- [Leo PR](https://github.com/ProvableHQ/leo/pull/28593)

To start using these features, we'll need to first set up custom development environment.

## Setting up Leo

You will need to clone the Leo repository and build from source.
```
> git clone https://github.com/ProvableHQ/leo.git
> cd leo
```
You can then install Leo with the following command:
```
> cargo install --locked --path . 
```

**Note: You will need to ensure that all of your Leo programs use `.env` file** that looks like this:
```
NETWORK=testnet
PRIVATE_KEY=APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH
ENDPOINT=http://localhost:3030
```
which will use a private key that is already funded and point to the local devnet.
Otherwise, you will need to manually pass in these values via the `--network`, `--private-key`, and `--endpoint` flags.

Other devnet private keys include:
- `APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh`
- `APrivateKey1zkp2GUmKbVsuc1NSj28pa1WTQuZaK5f1DQJAT6vPcHyWokG`
- `APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs`

## Running a Devnet

Leo v3.1.0 provides a simple way to run a local devnet. You may run 
```bash
leo devnet --help
```
to see the available options.

To quickly get started, you can run the following commands:
```bash
> mkdir tmp
> leo devnet --storage tmp --snarkos ./tmp/snarkos-test --features test_network --install
```
Note: You should omit the `--install` flag on subsequent runs.

## Trying Out Upgradable Programs

You can refer to one of the following tutorials to get started with upgradable programs:
- [Non-upgradable Programs](01_noupgrade.md)
- [Admin-based Upgrade](02_admin.md)
- [Timelocked Upgrade](03_timelock.md)
- [Vote-based Upgrade](04_vote.md)

