pragma solidity >=0.6.1;

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

    event Purchase(address from, address to, uint id, uint amount);

    modifier adminOnly() {
        require(msg.sender == _admin, "Only game admin can call this function.");
        _;
    }

    modifier checkPokemonId(uint id) {
        require(id >= 0 && id < _totalNumPokemon, "Pokemon id out of bounds");
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
        _pokForSale = [true, true];
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

    receive () external payable {
        _pendingWithdrawals[msg.sender] += msg.value;
    }

    function getOwner(uint id) external view checkPokemonId(id) returns (address owner) {
        return _pokOwner[id];
    }

    function addPokemon(
        bytes32 species,
        bytes32 pokemonType,
        uint price,
        uint8 level,
        bytes32 evolvesTo,
        uint8 timesCanBreed,
        bytes32 breedsTo
    ) public adminOnly() returns (uint idOfNewPokemon) {
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
        assert(_pokSpecies.length == _totalNumPokemon);
        assert(_pokOwner.length == _totalNumPokemon);
        return _totalNumPokemon - 1;
    }

    function buyPokemon(uint id) external payable checkPokemonId(id) returns (uint) {
        require(_pokOwner[id] != msg.sender, "You already own this pokemon");
        require(_pokPrice[id] == msg.value, "No payment received or wrong payment amount");
        require(_pokForSale[id], "This pokemon is not for sale");
        address seller = _pokOwner[id];
        _pendingWithdrawals[seller] += msg.value;
        _pokOwner[id] = msg.sender;
        _pokForSale[id] = false;
        _pokPrice[id] = 0;
        emit Purchase(seller, msg.sender, id, msg.value);
        return id;
    }

    function sellPokemon(uint id, uint amount) external checkPokemonId(id) {
        require(msg.sender == _pokOwner[id], "You do not own this pokemon");
        _pokForSale[id] = true;
        _pokPrice[id] = amount;
    }

    function checkBalance() external view returns (uint balance) {
        return _pendingWithdrawals[msg.sender];
    }

    function withdrawFunds() external returns (uint balanceTransferred) {
        require(_pendingWithdrawals[msg.sender] > 0, "You do not have any funds to withdraw");
        uint amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        address payable recipient = msg.sender;
        recipient.transfer(amount);
        return amount;
    }


}