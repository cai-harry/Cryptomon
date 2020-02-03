const Cryptomon = artifacts.require("Cryptomon");

contract("Cryptomon", accounts => {
    it("constructor", async () => {
        let contract = await Cryptomon.deployed();
        let owner = await contract._admin.call();
        assert.equal(owner, accounts[0]);
    });

    it("addPokemon", async () => {
        let contract = await Cryptomon.deployed();
        let id = await contract.addPokemon.call(
            "Tapu Koko",            // species
            "Electric",             // type
            web3.toWei(1, 'ether'), // price
            5,                      // level
            "Tapu Koko",            // evolvesTo
            0,                      // timesCanBreed
            "Tapu Koko"             // breedsTo
        );
        let newPokemon = await contract._pokemons.call(id);
        assert.equal(newPokemon.species, "Tapu Koko");
        assert.equal(newPokemon.owner, accounts[0]);
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