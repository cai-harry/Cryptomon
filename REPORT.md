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

![Initial state as normal user](readme_images/initial.png)

All Pokemon cards are listed with an option to buy, if they are for sale.

If they click on the Buy button, the app contacts their Ethereum wallet, in this example Metamask:

![When buying Stufful (ID 3)](readme_images/buy-confirm.png)

If they choose to sign this transaction, it is sent to the smart contract and the page refreshes.

![After buying Stufful](readme_images/bought-stufful.png)

### Selling Pokemon

Users can enter a price in ETH and list a Pokemon card for sale.

![Selling Stufful](readme_images/sell.png)

The user is prompted to sign the transaction:

![Selling Stufful Confirmation](readme_images/sell-confirm.png)

If they sign it, the card is listed for sale.

![Stufful listed for sale](readme_images/sell-listed.png)

Once another user buys this card, the price is added to the original owner's balance, and they can withdraw the Ether by clicking on Withdraw at the top.

![Stufful sold, Ether ready for withdrawal](readme_images/sold.png)

### Fighting Pokemon

Users can start a fight with any Pokemon they own.

They can only attack Pokemon which are not stunned.

The winner of fights is picked randomly using a RNG. The attacker's probability of winning is greater if they have a higher _Level_ than the defender, and vice versa. A Level 5 card will always win against a Level 1 card and a Level 1 card will always lose against a Level 5 card.

### Reviving Pokemon

A Pokemon card which loses a fight, whether as an attacker or a defender, is _stunned_ and gains Revive option.

![Stufful lost a fight](readme_images/stunned.png)

Reviving costs a fee of 0.01 ETH which is added to the balance of the game admin.

![Reviving Stufful](readme_images/revive-confirm.png)

### Evolving Pokemon

A Pokemon card which wins a fight, whether as an attacker or a defender, gains one level up and gains the Evolve option.

![Evolving Stufful after winning a fight](readme_images/evolve-confirm.png)

![Stufful evolved into a Bewear!](readme_images/evolved.png)

Evolving will revive a stunned Pokemon.

### Breeding Pokemon

Each Pokemon card can breed a certain amount of times, except some species such as Tapu Koko.

![Let's breed more Mimikyu's!](readme_images/breed-confirm.png)

The owner of a Pokemon card can use it to breed more cards. The 'children' of a Pokemon have a higher generation number, and start at level 1 and take the first evolution of that species.

Lower generation numbers are therefore rarer cards. The owner of a Pokemon card can breed infinitely many more cards, but can only breed a maximum number of each generation, and cannot breed any with the same or lower generation number as their original.

![After breeding Mimikyu's many times](readme_images/mimikyu-children.png)


### Admin Functions

No UI for admin

Example js code to add new species and cards
Need to change the javascript UI for users to see

## Security considerations

### RNG

A miner could exploit this to make sure they win all their battles: (explain how)

However, it would not make economic sense for them to do this; ... by playing the game as normal, they may lose some battles and have to pay the 0.01 ETH revive fee a few times before they can evolve their Pokemon cards. By using the above exploit they can win all their battles and avoid paying these revive fees, but they stand to make far more Ether from mining and publishing blocks immediately.

### Withdrawal pattern

When a user buys a Pokemon card, they send their Ether to the smart contract.

Instead of sending the Ether to the original owner straightaway, the smart contract keeps track of how much Ether the original owner is owed, and the original owner must call the smart contract to withdraw this Ether.

This is known as the Withdrawal Pattern and prevents attackers from trapping the contract in an unusable state, eg. by calling the smart contract via another smart contract whose fallback function always fails.[*](https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html#withdrawal-from-contracts)

### Preventing re-entrancy

Suppose an attacker creates a smart contract which calls into the Cryptomon contract, and tries a re-entrancy attack:

1. It buys a card
2. It lists the card up for sale and waits for someone to buy it
3. Once the card is sold, it calls `withdrawFunds()` to withdraw from its Ether balance.
4. In its fallback function, it calls `withdrawFunds()` again, in the hope of withdrawing the same balance infinitely many times.

This attack would not work because the Cryptomon contract sets the attacker's pending balance to zero **before** sending Ether to the attacker. So the attacker would only be sent its pending balance once, and then waste gas fees repeatedly calling `withdrawFunds()` to no effect.