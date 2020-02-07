pragma solidity >=0.6.1;

contract Cryptomon {
    address public _admin;

    uint public _totalNumPokemon;
    uint16[] public _pokSpeciesId;
    address[] public _pokOwner;
    bool[] public _pokForSale;
    uint[] public _pokPrice;
    uint8[] public _pokLevel;
    bool[] public _pokCanEvolve;
    bool[] public _pokStunned;
    uint8[] public _pokTimesCanBreed;
    uint[] public _pokGeneration;

    mapping(uint16 => uint8) public _speciesType;
    mapping(uint16 => uint16) public _speciesEvolvesTo;
    mapping(uint16 => uint16) public _speciesBreedsTo;
    mapping(uint16 => uint8) public _speciesTimesCanBreed;

    mapping (address => uint) public _pendingWithdrawals;

    uint public _revivePrice = 10 finney;

    event SpeciesDefined(uint16 speciesId);
    event PokemonAdded(uint pokId);
    event Purchase(address seller, address buyer, uint id, uint amount);
    event ListedForSale(uint id, uint amount);

    modifier adminOnly() {
        require(msg.sender == _admin, "Only game admin can call this function.");
        _;
    }

    modifier checkPokemonId(uint id) {
        require(id >= 0 && id < _totalNumPokemon, "Pokemon id out of bounds");
        _;
    }

    modifier checkOwnsPokemon(uint id) {
        require(_pokOwner[id] == msg.sender, "You do not own this pokemon");
        _;
    }

    constructor() public {
        _admin = msg.sender;
        _totalNumPokemon = 0;
    }

    function addInitialPokemon() external adminOnly() {
        require(_totalNumPokemon == 0, "Pokemon have already been added");
        defineSpecies(
            1, // Species: Tapu Koko 
            4, // Type: Electric 
            1, // Evolves to
            1, // Breeds to
            0 // Times can breed
        );
        defineSpecies(
            2, // Species: Tapu Lele
            17, // Type: Fairy
            2, 
            2, 
            0
        );
        addPokemon(1, 1 ether, true, 5);
        addPokemon(2, 1 ether, true, 5);
    }

    receive () external payable {
        _pendingWithdrawals[msg.sender] += msg.value;
    }

    function getOwner(uint id) external view checkPokemonId(id) returns (address owner) {
        return _pokOwner[id];
    }

    function defineSpecies(
        uint16 speciesId, uint8 speciesType, uint16 evolvesTo, uint16 breedsTo, uint8 timesCanBreed
    ) public adminOnly() {
        _speciesType[speciesId] = speciesType;
        _speciesEvolvesTo[speciesId] = evolvesTo;
        _speciesBreedsTo[speciesId] = breedsTo;
        _speciesTimesCanBreed[speciesId] = timesCanBreed;
        emit SpeciesDefined(speciesId);
    }

    function addPokemon(
        uint16 species,
        uint price,
        bool forSale,
        uint8 level
    ) public adminOnly() {
        require(_speciesType[species] != 0, "The type for this species hasn't been defined");
        require(_speciesEvolvesTo[species] != 0, "The next evolution for this species hasn't been defined");
        require(_speciesBreedsTo[species] != 0, "The first evolution on birth for this species hasn't been defined");
        _totalNumPokemon += 1;
        _pokSpeciesId.push(species);
        _pokOwner.push(_admin);
        _pokForSale.push(forSale);
        _pokPrice.push(price);
        _pokLevel.push(level);
        _pokCanEvolve.push(false);
        _pokStunned.push(false);
        _pokTimesCanBreed.push(_speciesTimesCanBreed[species]);
        _pokGeneration.push(0);
        emit PokemonAdded(_totalNumPokemon - 1);
    }

    function setRevivePrice(uint price) external adminOnly() {
        _revivePrice = price;
    }

    function buyPokemon(uint id) external payable checkPokemonId(id) {
        require(_pokOwner[id] != msg.sender, "You already own this pokemon");
        require(_pokPrice[id] == msg.value, "No payment received or wrong payment amount");
        require(_pokForSale[id], "This pokemon is not for sale");
        address seller = _pokOwner[id];
        _pendingWithdrawals[seller] += msg.value;
        _pokOwner[id] = msg.sender;
        _pokForSale[id] = false;
        _pokPrice[id] = 0;
        emit Purchase(seller, msg.sender, id, msg.value);
    }

    function sellPokemon(uint id, uint amount) external checkPokemonId(id) checkOwnsPokemon(id) {
        _pokForSale[id] = true;
        _pokPrice[id] = amount;
        emit ListedForSale(id, amount);
    }

    function fight(uint usingId, uint againstId) external checkPokemonId(usingId) checkPokemonId(againstId) checkOwnsPokemon(usingId) {
        require(!_pokStunned[usingId], "This pokemon is stunned");
        uint8 rand = random();
        uint8 advantage = _pokLevel[usingId] - _pokLevel[againstId];
        uint8 winThreshold = 4 + advantage;
        uint winner;
        uint loser;
        if (rand >= winThreshold) {
            winner = usingId;
            loser = againstId;
        } else {
            winner = againstId;
            loser = usingId;
        }
        _pokLevel[winner] += 1;
        _pokCanEvolve[winner] = true;
        _pokStunned[loser] = true;
    }

    function evolve(uint id) external checkPokemonId(id) checkOwnsPokemon(id) {
        require(_pokCanEvolve[id], "This pokemon is not ready to evolve");
        _pokCanEvolve[id] = false;
        _pokStunned[id] = false;
        _pokSpeciesId[id] = _speciesEvolvesTo[_pokSpeciesId[id]];
    }

    function revive(uint id) external payable checkPokemonId(id) checkOwnsPokemon(id) {
        require(_pokStunned[id], "This pokemon is not stunned");
        require(msg.value == _revivePrice, "No or wrong payment amount for revive");
        _pendingWithdrawals[_admin] += msg.value;
        _pokStunned[id] = false;
    }

    function breed(uint id) external checkPokemonId(id) checkOwnsPokemon(id) {
        require(_pokTimesCanBreed[id] > 0, "This pokemon cannot or can no longer breed");
        _pokTimesCanBreed[id] -= 1;
        addPokemon(_speciesBreedsTo[_pokSpeciesId[id]], 0, false, 1);
    }

    function checkBalance() external view returns (uint balance) {
        return _pendingWithdrawals[msg.sender];
    }

    function withdrawFunds() external {
        require(_pendingWithdrawals[msg.sender] > 0, "You do not have any funds to withdraw");
        uint amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        address payable recipient = msg.sender;
        recipient.transfer(amount);
    }

    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 251);
    }

}