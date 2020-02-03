const Cryptomon = artifacts.require("Cryptomon");

contract("Cryptomon", accounts => {
    it("constructor", async () => {
        let contract = await Cryptomon.deployed();
        let owner = await contract._admin.call();
        assert.equal(owner, accounts[0]);
    });

    it("addPokemon", async () => {
        let contract = await Cryptomon.deployed();
        let result = await contract.addPokemon.call(
            web3.utils.fromAscii("Mimikyu"),    // species
            web3.utils.fromAscii("Dark"),       // type
            web3.utils.toWei('1', "ether"),     // price
            3,                                  // level
            web3.utils.fromAscii("Mimikyu"),    // evolvesTo
            2,                                  // timesCanBreed
            web3.utils.fromAscii("Mimikyu"),    // breedsTo
            { from: accounts[0] }
        );
        let id = parseInt(result);
        assert.equal(id, 2);
        // TODO: these cause an invalid opcode error. Why?
        // let newPokemonOwner = await contract.getOwner.call(id);
        // assert.equal(newPokemonOwner, accounts[0]);
        // let newPokemonSpecies = await contract._pokSpecies.call(id);
        // assert.equal(newPokemonSpecies, "Tapu Koko");
    });

    it("getIdsForSale", async () => {
        let contract = await Cryptomon.deployed();
    });

    it("getIdsOwnedBy", async () => {
        let contract = await Cryptomon.deployed();
    });

    it("buyPokemon", async () => {
        let contract = await Cryptomon.deployed();
    });

    it("sellPokemon", async () => {
        let contract = await Cryptomon.deployed();
    });

    it("withdrawFunds", async () => {
        let contract = await Cryptomon.deployed();
    });


});