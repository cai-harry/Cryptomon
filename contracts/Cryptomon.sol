pragma solidity ^0.5.0;

contract Cryptomon {
    address public _admin;

    uint public _totalNumPokemon;
    bytes32[] public _pokSpecies;
    bytes32[] public _pokType;
    address[] public _pokOwner;
    bool[] public _pokForSale;
    uint[] public _pokPrice;
    uint8[] public _pokLevel;
    bool[] public _pokStunned;
    bytes32[] public _pokEvolvesTo;
    uint8[] public _pokTimesCanBreed;
    uint[] public _pokGeneration;
    bytes32[] public _pokBreedsTo;

    uint[] public _idsForSale;
    mapping(address => uint[]) public _idsByOwner;

    mapping (address => uint) public _pendingWithdrawals;

    modifier adminOnly() {
        require(msg.sender == _admin, "Only admin can call this function.");
        _;
    }

    constructor() public {
        // TODO: refactor
        _admin = msg.sender;
        _pokSpecies.push("Tapu Koko");
        _pokSpecies.push("Tapu Lele");
        _pokType.push("Electric");
        _pokType.push("Fairy");
        _pokOwner = [_admin, _admin];
        _pokForSale = [false, false];
        _pokPrice = [1 ether, 1 ether];
        _pokLevel = [5, 5];
        _pokStunned = [false, false];
        _pokEvolvesTo.push("Tapu Koko");
        _pokEvolvesTo.push("Tapu Lele");
        _pokTimesCanBreed = [0, 0];
        _pokGeneration = [0, 0];
        _pokBreedsTo.push("Tapu Koko");
        _pokBreedsTo.push("Tapu Lele");
        _totalNumPokemon = 2;
    }

    function getOwner(uint id) external view returns (address owner) {
        return _pokOwner[id];
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
    ) external returns (uint) {
        _totalNumPokemon += 1;
        _pokSpecies.push(species);
        _pokType.push(pokemonType);
        _pokOwner.push(_admin);
        _pokForSale.push(false);
        _pokPrice.push(price);
        _pokLevel.push(level);
        _pokStunned.push(false);
        _pokEvolvesTo.push(evolvesTo);
        _pokTimesCanBreed.push(timesCanBreed);
        _pokGeneration.push(0);
        _pokBreedsTo.push(breedsTo);
        uint idOfNewPokemon = _totalNumPokemon - 1;
        return idOfNewPokemon;
    }

    function buyPokemon(uint id) external payable returns (uint) {
        require(id >= 0 && id < _totalNumPokemon, "id out of bounds");
        require(_pokPrice[id] == msg.value, "No payment received or wrong payment amount");
        require(_pokForSale[id], "The specified pokemon is not for sale");
        _pendingWithdrawals[_pokOwner[id]] += msg.value;
        _pokOwner[id] = msg.sender;
        _pokForSale[id] = false;
        _pokPrice[id] = 0;
        return id;
    }

    function sellPokemon(uint id, uint amount) external {
        _pokForSale[id] = true;
        _pokPrice[id] = amount;
    }

    function withdrawFunds() external {
        uint amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}