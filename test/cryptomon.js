const Cryptomon = artifacts.require("Cryptomon");

contract("Cryptomon", accounts => {
    it("int test, admin setup", async () => {
        let contract = await Cryptomon.deployed();
        let owner = await contract._admin.call();
        assert.equal(owner, accounts[0]);

        let numAdded = await contract.addInitialPokemon();
        let numPokemon = await contract._totalNumPokemon.call();
        assert.equal(numAdded, numPokemon);
        assert.equal(numPokemon, 2);

        let firstPokemonSpecies = web3.utils.hexToUtf8(
            await contract._pokSpecies.call(0));
        assert.equal(firstPokemonSpecies, "Tapu Koko");
    });

    it("int test, admin adding new species and cards", async () => {
        let contract = await Cryptomon.deployed();
        let result1 = await contract.defineSpecies.call(
            web3.utils.utf8ToHex("Mimikyu"),    // species
            web3.utils.utf8ToHex("Dark"),       // type
            web3.utils.utf8ToHex("Mimikyu"),    // evolvesTo
            web3.utils.utf8ToHex("Mimikyu"),    // breedsTo
            2,                                  // timesCanBreed
            { from: accounts[0] }
        )
        let result2 = await contract.addPokemon.call(
            web3.utils.utf8ToHex("Mimikyu"),    // species
            web3.utils.toWei('0.1', "ether"),   // price
            true,                               // forSale
            3,                                  // level
            { from: accounts[0] }
        );
        let id = result2.toNumber();
        assert.equal(id, 2);
        let newPokemonOwner = debug(await contract.getOwner.call(id));
        assert.equal(newPokemonOwner, accounts[0]);
        let newPokemonSpecies = await contract._pokSpecies.call(2);
        assert.equal(newPokemonSpecies, "Mimikyu");
    });

    it("int test buying and selling pokemon", async () => {
        let contract = await Cryptomon.deployed();
        let id = 1;
        let price = web3.utils.toWei('1', 'ether');
        let resultBuy = await contract.buyPokemon.call(id, {from:accounts[1], value:price});
        let idBought = resultBuy.toNumber();
        assert.equal(idBought, id);
        let newOwner = await contract._pokOwner.call(idBought);
        assert.equal(newOwner, accounts[1]);
        
        let resultSell = await contract.buyPokemon.call(id, {from:accounts[1], value:price});
        let resultBuy2 = await contract.buyPokemon.call(id, {from:accounts[2], value:price});
        let newOwner2 = await contract._pokOwner.call(idBought);
        assert.equal(newOwner, accounts[2]);
    });

    it("int test depositing and withdrawing funds", async () => {
        let contract = await Cryptomon.deployed();
        let balanceBefore = parseInt(await web3.eth.getBalance(accounts[1]));
        let amount = parseInt(web3.utils.toWei('100', 'finney'));
        let result = await contract.sendTransaction({from:accounts[1], value:amount});
        let balanceInContract = parseInt(await contract.checkBalance.call({from:accounts[1]}));
        assert.equal(balanceInContract, amount);
        let balanceAfter = parseInt(await web3.eth.getBalance(accounts[1]));
        assert.isAtLeast(balanceBefore, balanceAfter + amount); // not testing for equality because gas

        let result2 = await contract.withdrawFunds.call({from: accounts[1]});
        let balanceFinal = parseInt(await web3.eth.getBalance(accounts[1]));
        assert.isAtLeast(balanceFinal, balanceAfter);
    });


});