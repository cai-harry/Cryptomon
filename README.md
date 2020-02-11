# Cryptomon

[See the report here](REPORT.md)

Requirements
- [Node.js v8+ LTS and npm](https://nodejs.org/en/) (comes with Node)
- Truffle (`npm install -g truffle`)
- [Ganache](https://www.trufflesuite.com/ganache)
- [Metamask](https://metamask.io/) or similar

## Compile contract
```
truffle compile
```

The compiled contract will be at `build/Cryptomon.json`

## Deploy

First start Ganache. Make sure the network is running on port 7545.

```
truffle migrate
```

Note: I edited the migration script to automatically calls `Cryptomon.addInitialPokemon()` (see `migrate/2_deploy_contracts.js`)

## Run tests
```
truffle test
```

## Start the server
```
npm run dev
```