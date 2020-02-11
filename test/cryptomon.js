const Cryptomon = artifacts.require("Cryptomon");

contract("Cryptomon", accounts => {
    it("int test, admin setup", async () => {
        let contract = await Cryptomon.deployed();
        let owner = await contract._admin.call();
        assert.equal(owner, accounts[0]);

        let firstPokemonSpecies = parseInt(
            await contract._pokSpeciesId.call(0));
        assert.equal(firstPokemonSpecies, 1);
    });

    it("int test, admin adding new species and cards", async () => {
        let contract = await Cryptomon.deployed();
        await contract.defineSpecies.sendTransaction(
            65535, // species (very large number to not collide with 'real' speciesIds)
            15,    // type
            65535, // evolvesTo
            65535, // breedsTo
            2,     // timesCanBreed
            { from: accounts[0] }
        );
        await contract.addPokemon.sendTransaction(
            65535,                              // species
            web3.utils.toWei('100', "finney"),  // price
            true,                               // forSale
            1,                                  // level
            { from: accounts[0] }
        );

        let newId = parseInt(await contract._totalNumPokemon.call()) - 1;
        let newPokemonOwner = await contract.getOwner.call(newId);
        assert.equal(newPokemonOwner, accounts[0]);
        let newPokemonSpecies = await contract._pokSpeciesId.call(newId);
        assert.equal(newPokemonSpecies, 65535);
    });

    it("int test buying and selling pokemon", async () => {
        let contract = await Cryptomon.deployed();
        let id = 3;
        let price = await contract._pokPrice.call(id);
        await contract.buyPokemon.sendTransaction(id, { from: accounts[1], value: price });

        let newOwner = await contract._pokOwner.call(id);
        assert.equal(newOwner, accounts[1]);

        let newPrice = web3.utils.toWei('550', 'finney');

        await contract.sellPokemon.sendTransaction(id, newPrice, { from: accounts[1] });
        let forSale = await contract._pokForSale.call(id);
        let listedPrice = parseInt(await contract._pokPrice.call(id));
        assert.isOk(forSale);
        assert.equal(listedPrice, newPrice);

        await contract.buyPokemon.sendTransaction(id, { from: accounts[2], value: newPrice });

        newOwner = await contract._pokOwner.call(id);
        assert.equal(newOwner, accounts[2]);
    });

    it("int test fighting and reviving", async () => {
        let contract = await Cryptomon.deployed();

        let alwaysWins = 0;
        let alwaysLoses = 6;

        // lv 5 Tapu Koko vs lv 1 Mimikyu, guaranteed win
        await contract.fight.sendTransaction(alwaysWins, alwaysLoses);
        assert.isOk(await contract._pokStunned.call(alwaysLoses));

        let revivePrice = web3.utils.toWei('0.01', 'ether');
        await contract.revive.sendTransaction(alwaysLoses, { value: revivePrice });
        assert.isNotOk(await contract._pokStunned.call(alwaysLoses));

        // lv 1 Mimikyu vs lv 5 Tapu Koko, guaranteed loss
        await contract.fight.sendTransaction(alwaysLoses, alwaysWins);
        assert.isOk(await contract._pokStunned.call(alwaysLoses));
        await contract.revive.sendTransaction(alwaysLoses, { value: revivePrice });
    });

    it("int test evolving", async () => {
        let contract = await Cryptomon.deployed();

        // Stufful vs Bounsweet
        await contract.fight.sendTransaction(2, 8);

        if (await contract._pokStunned.call(2)) {
            // Bounsweet won
            await contract.evolve.sendTransaction(8);
            assert.equal(await contract._pokSpeciesId.call(8), 18) // 18 = Steenee
        } else {
            // Stufful won
            await contract.evolve.sendTransaction(2);
            assert.equal(await contract._pokSpeciesId.call(2), 4) // 4 = Bewear
        }
    });

    it("int test breeding", async () => {
        let contract = await Cryptomon.deployed();

        // unleash a terrifying flurry of Mimikyus
        await contract.breed.sendTransaction(6);
        let newestId = parseInt(await contract._totalNumPokemon.call()) - 1;
        assert.equal(await contract._pokSpeciesId.call(newestId), 13);
        assert.equal(await contract._pokGeneration.call(newestId), 1);
        await contract.breed.sendTransaction(newestId);
        newestId = parseInt(await contract._totalNumPokemon.call()) - 1;
        assert.equal(await contract._pokSpeciesId.call(newestId), 13);
        assert.equal(await contract._pokGeneration.call(newestId), 2);

    });

    it("int test depositing and withdrawing funds", async () => {
        let contract = await Cryptomon.deployed();
        let balanceBefore = parseInt(await web3.eth.getBalance(accounts[2]));
        let amount = parseInt(web3.utils.toWei('100', 'finney'));
        let result = await contract.sendTransaction({ from: accounts[2], value: amount });
        let balanceInContract = parseInt(await contract.checkBalance.call({ from: accounts[2] }));
        assert.equal(balanceInContract, amount);
        let balanceAfter = parseInt(await web3.eth.getBalance(accounts[2]));
        assert.isAtLeast(balanceBefore, balanceAfter + amount); // not testing for equality because gas

        let result2 = await contract.withdrawFunds.sendTransaction({ from: accounts[2] });
        let balanceFinal = parseInt(await web3.eth.getBalance(accounts[2]));
        assert.isAtLeast(balanceFinal, balanceAfter);
    });

    after("tidying up", async () => {
        let contract = await Cryptomon.deployed();
        for (let i = 0; i < accounts.length; i++) {
            let balance = parseInt(await contract.checkBalance.call({ from: accounts[i] }));
            if (balance > 0) {
                await contract.withdrawFunds.sendTransaction({ from: accounts[i] });
            }
        }
    });


});