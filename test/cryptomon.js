const Cryptomon = artifacts.require("Cryptomon");

// TODO: a proper story going through every path

contract("Cryptomon", accounts => {
    it("int test, admin setup", async () => {
        let contract = await Cryptomon.deployed();
        let owner = await contract._admin.call();
        assert.equal(owner, accounts[0]);

        await contract.addInitialPokemon();
        let numPokemon = parseInt(await contract._totalNumPokemon.call());
        assert.equal(numPokemon, 2);

        let firstPokemonSpecies = parseInt(
            await contract._pokSpeciesId.call(0));
        assert.equal(firstPokemonSpecies, 1);
    });

    it("int test, admin adding new species and cards", async () => {
        let contract = await Cryptomon.deployed();
        await contract.defineSpecies.sendTransaction(
            11,    // species
            15,    // type
            11,    // evolvesTo
            11,    // breedsTo
            2,     // timesCanBreed
            { from: accounts[0] }
        );
        await contract.addPokemon.sendTransaction(
            11,                                 // species
            web3.utils.toWei('0.1', "ether"),   // price
            true,                               // forSale
            1,                                  // level
            { from: accounts[0] }
        );

        let newId = parseInt(await contract._totalNumPokemon.call()) - 1;
        let newPokemonOwner = await contract.getOwner.call(newId);
        assert.equal(newPokemonOwner, accounts[0]);
        let newPokemonSpecies = await contract._pokSpeciesId.call(2);
        assert.equal(newPokemonSpecies, 11);
    });

    it("int test buying and selling pokemon", async () => {
        let contract = await Cryptomon.deployed();
        let id = 2;
        let price = web3.utils.toWei('0.1', 'ether');
        await contract.buyPokemon.sendTransaction(id, {from:accounts[1], value:price});
        
        let newOwner = await contract._pokOwner.call(id);
        assert.equal(newOwner, accounts[1]);
        
        let newPrice = web3.utils.toWei('2', 'ether');

        await contract.sellPokemon.sendTransaction(id, newPrice, {from:accounts[1]});
        let forSale = await contract._pokForSale.call(id);
        let listedPrice = parseInt(await contract._pokPrice.call(id));
        assert.isOk(forSale);
        assert.equal(listedPrice, newPrice);

        await contract.buyPokemon.sendTransaction(id, {from:accounts[2], value:newPrice});
        
        newOwner = await contract._pokOwner.call(id);
        assert.equal(newOwner, accounts[2]);
    });

    it("int test fighting and reviving", async () => {
        let contract = await Cryptomon.deployed();

        // lv 5 Tapu Koko vs lv 1 Mimikyu, guaranteed win
        await contract.fight.sendTransaction(0, 2, {from:accounts[0]});
        assert.isOk(await contract._pokStunned.call(2));

        let revivePrice = web3.utils.toWei('0.01', 'ether');
        await contract.revive.sendTransaction(2, {from:accounts[2], value:revivePrice});
        assert.isNotOk(await contract._pokStunned.call(2));

        // lv 1 Mimikyu vs lv 5 Tapu Koko, guaranteed loss
        await contract.fight.sendTransaction(2, 0, {from:accounts[2]});
        assert.isOk(await contract._pokStunned.call(2));
    });

    it("int test depositing and withdrawing funds", async () => {
        let contract = await Cryptomon.deployed();
        let balanceBefore = parseInt(await web3.eth.getBalance(accounts[2]));
        let amount = parseInt(web3.utils.toWei('100', 'finney'));
        let result = await contract.sendTransaction({from:accounts[2], value:amount});
        let balanceInContract = parseInt(await contract.checkBalance.call({from:accounts[2]}));
        assert.equal(balanceInContract, amount);
        let balanceAfter = parseInt(await web3.eth.getBalance(accounts[2]));
        assert.isAtLeast(balanceBefore, balanceAfter + amount); // not testing for equality because gas

        let result2 = await contract.withdrawFunds.sendTransaction({from: accounts[2]});
        let balanceFinal = parseInt(await web3.eth.getBalance(accounts[2]));
        assert.isAtLeast(balanceFinal, balanceAfter);
    });

    after("tidying up", async () => {
        let contract = await Cryptomon.deployed();
        for (let i = 0; i < accounts.length; i++) {
            let balance = parseInt(await contract.checkBalance.call({from: accounts[i]}));
            if (balance > 0) {
                await contract.withdrawFunds.sendTransaction({from: accounts[i]});
            }
        }
    });


});