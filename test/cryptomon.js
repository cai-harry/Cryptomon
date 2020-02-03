const Cryptomon = artifacts.require("Cryptomon");

contract("Cryptomon", accounts => {
    it("test constructor", async () => {
        let contract = await Cryptomon.deployed();
        let owner = await contract._admin.call();
        assert.equal(owner, accounts[0]);

        let numPokemon = await contract._totalNumPokemon.call();
        assert.equal(numPokemon, 2);

        let firstPokemonSpecies = web3.utils.hexToUtf8(
            await contract._pokSpecies.call(0));
        assert.equal(firstPokemonSpecies, "Tapu Koko");
    });

    it("test addPokemon", async () => {
        let contract = await Cryptomon.deployed();
        let result = await contract.addPokemon.call(
            web3.utils.utf8ToHex("Mimikyu"),    // species
            web3.utils.utf8ToHex("Dark"),       // type
            web3.utils.toWei('1', "ether"),     // price
            3,                                  // level
            web3.utils.utf8ToHex("Mimikyu"),    // evolvesTo
            2,                                  // timesCanBreed
            web3.utils.utf8ToHex("Mimikyu"),    // breedsTo
            { from: accounts[0] }
        );
        let id = result.toNumber();
        assert.equal(id, 2);
        // TODO: these cause an invalid opcode error. Why?
        let newPokemonOwner = debug(await contract.getOwner.call(id));
        assert.equal(newPokemonOwner, accounts[0]);
        let newPokemonSpecies = await contract._pokSpecies.call(2);
        assert.equal(newPokemonSpecies, "Tapu Koko");
    });

    // it("test getIdsForSale", async () => {
    //     let contract = await Cryptomon.deployed();
    // });

    // it("test getIdsOwnedBy", async () => {
    //     let contract = await Cryptomon.deployed();
    // });

    it("test buyPokemon", async () => {
        let contract = await Cryptomon.deployed();
        let idToBuy = 1;
        let player1 = accounts[1];
        let price = web3.utils.toWei('1', 'ether');
        let result = await contract.buyPokemon.call(idToBuy, {from:player1, value:price});
        let idBought = result.toNumber();
        assert.equal(idBought, idToBuy);
        let newOwner = await contract._pokOwner.call(idBought);
        assert.equal(newOwner, player1);
    });

    it("test sellPokemon", async () => {
        let contract = await Cryptomon.deployed();
        let player1 = accounts[1];
    });

    it("test withdrawFunds", async () => {
        let contract = await Cryptomon.deployed();
    });


});