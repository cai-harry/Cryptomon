# Cryptomon

[See the report here](REPORT.md)

Requirements
- [Node.js v8+ LTS and npm](https://nodejs.org/en/) (comes with Node)
- [Git](https://git-scm.com/downloads)
- Truffle (`npm install -g truffle`)
- [Ganache](https://www.trufflesuite.com/ganache)

## Compile
```
truffle compile
```

## Deploy
```
truffle migrate
```

Note: the migration script automatically calls `Cryptomon.addInitialPokemon()` (see `migrate/2_deploy_contracts.js`)

## Run tests
```
truffle test
```

## Start the server
```
npm run dev
```