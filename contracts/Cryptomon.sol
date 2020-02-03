pragma solidity ^0.6.1;
pragma experimental ABIEncoderV2; // to return Pokemon struct

contract Cryptomon {

    struct Pokemon {
        bytes32 pokemonSpecies;
        bytes32 pokemonType;
        address owner;
        bool forSale;
        uint price;
        uint8 level;
        bool stunned;
        bytes32 evolvesTo;
        uint8 timesCanBreed;
        uint generation;
        bytes32 breedsTo;
    }

    address public _admin;

    Pokemon[] public _pokemons;
    uint[] public _pokemonsForSale;
    mapping(address => uint[]) public _pokemonsByOwner;

    mapping (address => uint) public _pendingWithdrawals;

    modifier adminOnly() {
        require(msg.sender == _admin, "Only admin can call this function.");
        _;
    }

    constructor() public {
        _admin = msg.sender;
    }

    function getPokemon(uint id) external view returns (Pokemon memory) {
        Pokemon memory requested = _pokemons[id];
        return requested;
    }

    // function getIdsForSale() public view returns (uint[] memory ids) {
    //     for (uint id = 0; id < _pokemons.length; id++) {
    //         if(_pokemons[id].forSale){
    //             ids.push(id);
    //         }
    //     }
    //     return ids;
    // }

    // function getIdsOwnedBy(address account) public view returns (uint[] memory ids) {
    //     for (uint id = 0; id < _pokemons.length; id++) {
    //         if(_pokemons[id].owner == account){
    //             ids.push(id);
    //         }
    //     }
    //     return ids;
    // }

    function addPokemon(
        bytes32 species,
        bytes32 pokemonType,
        uint price,
        uint8 level,
        bytes32 evolvesTo,
        uint8 timesCanBreed,
        bytes32 breedsTo
    ) external adminOnly() returns (uint) {
        Pokemon memory newPokemon = Pokemon({
            pokemonSpecies: species,
            pokemonType: pokemonType,
            owner: _admin,
            forSale: true,
            price: price,
            level: level,
            stunned: false,
            evolvesTo: evolvesTo,
            timesCanBreed: timesCanBreed,
            generation: 0,
            breedsTo: breedsTo
        });
        _pokemons.push(newPokemon);
        uint idOfNewPokemon = _pokemons.length - 1;
        return idOfNewPokemon;
    }

    function buyPokemon(uint id) external payable returns (uint) {
        require(id >= 0 && id <= _pokemons.length, "id out of bounds");
        Pokemon storage pokemon = _pokemons[id];
        require(pokemon.price == msg.value, "No payment received or wrong payment amount");
        require(pokemon.forSale, "The specified pokemon is not for sale");
        _pendingWithdrawals[pokemon.owner] += msg.value;
        pokemon.owner = msg.sender;
        pokemon.forSale = false;
        pokemon.price = 0;
        return id;
    }

    function sellPokemon(uint id, uint amount) external {
        Pokemon storage pokemon = _pokemons[id];
        pokemon.forSale = true;
        pokemon.price = amount;
    }

    function withdrawFunds() external {
        uint amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}