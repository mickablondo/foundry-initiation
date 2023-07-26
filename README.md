## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

### Personal Doc
```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup

forge --version
forge 0.2.0 (0e33b3e 2023-07-26T00:20:00.310757040Z)

forge init

npm install @openzeppelin/contracts
forge compile
```

Lancement d'une blockchain locale (anvil) et déploiement du contrat
```sh
anvil
forge create PadelConnect --interactive
```

Sur blockchain Anvil temporaire :  
```sh
forge script script/DeployPadelConnect.s.sol
```

Sur blockchain locale Anvil :  
```sh
forge script script/DeployPadelConnect.s.sol --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY> --broadcast

cast send <CONTRACT_ADDRESS> "addManager((address))" "(<AN_ADRESSE>)" --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY>
cast call <CONTRACT_ADDRESS> "owner()" --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY>
```
## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
