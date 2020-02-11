# Cryptomon Report

## Project Architecture

_Cryptomon_ is a Decentralised App allowing users to take part in a multiplayer Pokemon card game. It consists of a smart contract, (`Cryptomon.sol`) meant to be deployed on the Ethereum Blockchain, which acts as the 'backend', ie. the 'game server'. It keeps track of the status (ie. ownership, stats, etc.) of each Pokemon card and implements game logic.

Users interact with the smart contract via a JavaScript 'frontend' (see `src/`) which handles calls and transactions to the smart contract - displaying returned game data in human-friendly form, and providing a webpage UI to interact with it.

In order to make these calls and transactions, this web UI assumes the user has a web3 provider such as Metamask or MEW installed and activated. The web3 provider stores the user's private key and signs transactions with it. 

## Gameplay

### Starting State

Whichever address deploys the smart contract, `Cryptomon.sol`, to the blockchain is designated as the _Admin_.

When first deployed the contract is in an empty state with no Pokemon cards.

The _Admin_ can call `addInitialPokemon()` which will define and add a few Pokemon cards of different species. To begin with they are all owned by the Admin and listed for sale at different prices.

### Buying Pokemon

When playing for the first time, a normal user would see a screen such as this:

TODO

All Pokemon cards are listed with an option to buy, if they are for sale.

If they click on the Buy button, the app contacts their Ethereum wallet, in this example Metamask:

If they choose to sign this transaction, it is sent to the smart contract and the page refreshes.

### Selling Pokemon

Users can enter a price in ETH and list a Pokemon card for sale.

TODO

The user is prompted to sign the transaction:

TODO

If they sign it, the card is listed for sale.

Once another user buys this card, the price is added to the original owner's balance, and they can withdraw the Ether by clicking on Withdraw.

### Fighting Pokemon

Users can start a fight with any Pokemon they own.

They can only attack Pokemon which are not stunned.

The winner of fights is picked randomly using a RNG. The attacker's probability of winning is greater if they have a higher _Level_ than the defender, and vice versa. A Level 5 card will always win against a Level 1 card and a Level 1 card will always lose against a Level 5 card.

### Evolving Pokemon

A Pokemon card which wins a fight, whether as an attacker or a defender, gains the Evolve option. Its owner can do this at any time.

TODO: image

Evolving will revive a stunned Pokemon.

### Reviving Pokemon

A Pokemon card which loses a fight, whether as an attacker or a defender, is _stunned_ and gains Revive option.

TODO: image

Reviving costs a fee of 0.01 ETH which is added to the balance of the game admin.

### Breeding Pokemon

TODO

### Admin Functions

No UI for admin

Example js code to add new species and cards
Need to change the javascript UI for users to see

## Security considerations

### Withdrawal pattern

When a user buys a Pokemon card, they send their Ether to the smart contract.

Instead of sending the Ether to the original owner straightaway, the smart contract keeps track of how much Ether the original owner is owed, and the original owner must call the smart contract to withdraw this Ether.

This is known as the Withdrawal Pattern and prevents attackers from trapping the contract in an unusable state, eg. by calling the smart contract via another smart contract whose fallback function always fails.[*](https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html#withdrawal-from-contracts)

### RNG

A miner could exploit this to make sure they win all their battles: (explain how)

However, it would not make economic sense for them to do this; ... by playing the game as normal, they may lose some battles and have to pay the 0.01 ETH revive fee a few times before they can evolve their Pokemon cards. By using the above exploit they can win all their battles and avoid paying these revive fees, but they stand to make far more Ether from mining and publishing blocks immediately.

### Preventing re-entrancy
