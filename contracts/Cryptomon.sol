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
    uint8[] public _pokGeneration;

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
    event Fight(uint attacker, uint defender, uint8 rand, uint8 winRate256, uint winner);

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
        defineSpecies(1, 4, 1, 1, 0); // Tapu Koko
        defineSpecies(2, 17, 2, 2, 0); // Tapu Lele
        defineSpecies(3, 0, 4, 3, 1); // Stufful
        defineSpecies(4, 0, 4, 3, 1); // Bewear
        defineSpecies(5, 3, 6, 5, 2); // Rowlet
        defineSpecies(6, 3, 7, 5, 2); // Dartrix
        defineSpecies(7, 3, 7, 5, 2); // Decidueye
        defineSpecies(8, 12, 9, 8, 2); // Rockruff
        defineSpecies(9, 12, 9, 8, 2); // Lycanroc
        defineSpecies(10, 1, 11, 10, 2); // Litten
        defineSpecies(11, 1, 12, 10, 2); // Torracat
        defineSpecies(12, 1, 12, 10, 2); // Incineroar
        defineSpecies(13, 15, 13, 13, 2); // Mimikyu
        defineSpecies(14, 2, 15, 14, 2); // Popplio
        defineSpecies(15, 2, 16, 14, 2); // Brionne
        defineSpecies(16, 2, 16, 14, 2); // Primarina
        defineSpecies(17, 3, 18, 17, 2); // Bounsweet
        defineSpecies(18, 3, 19, 17, 2); // Steenee
        defineSpecies(19, 3, 19, 17, 2); // Tsareena

        addPokemon(1,  1 ether,    true, 5);
        addPokemon(2,  1 ether,    true, 5);
        addPokemon(3,  200 finney, true, 1);
        addPokemon(5,  100 finney, true, 1);
        addPokemon(8,  100 finney, true, 1);
        addPokemon(10, 100 finney, true, 1);
        addPokemon(13, 100 finney, true, 1);
        addPokemon(14, 100 finney, true, 1);
        addPokemon(17, 100 finney, true, 1);
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
        uint16 species, uint price, bool forSale, uint8 level
    ) public adminOnly() {
        _addPokemon(species, 0, price, forSale, level, _admin);
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

    function fight(uint attacker, uint defender) external checkPokemonId(attacker) checkPokemonId(defender) checkOwnsPokemon(attacker) {
        require(!_pokStunned[attacker], "This pokemon is stunned");
        require(!_pokStunned[defender], "Cannot attack a stunned pokemon");
        uint8 rand = _random();
        uint8 advantage = _pokLevel[attacker] - _pokLevel[defender]; // +4 => certain win, -4 => certain loss
        uint8 winRate256 = 2 ** (4 + advantage) - 1; // 256 => 100% win rate
        uint winner;
        uint loser;
        if (rand <= winRate256) {
            winner = attacker;
            loser = defender;
        } else {
            winner = defender;
            loser = attacker;
        }
        if (_pokLevel[winner] < 5) {
            _pokLevel[winner] += 1;
        }
        if (_speciesEvolvesTo[_pokSpeciesId[winner]] != _pokSpeciesId[winner]) {
            _pokCanEvolve[winner] = true;
        }
        _pokStunned[loser] = true;

        emit Fight(attacker, defender, rand, winRate256, winner);
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
        require(!_pokStunned[id], "This pokemon is stunned");
        _pokTimesCanBreed[id] -= 1;
        _addPokemon(
            _speciesBreedsTo[_pokSpeciesId[id]], 
            _pokGeneration[id] + 1,
            0, 
            false, 
            1,
            msg.sender
        );
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

    function _addPokemon(
        uint16 species,
        uint8 generation,
        uint price,
        bool forSale,
        uint8 level,
        address owner
    ) internal {
        require(_speciesEvolvesTo[species] != 0, "The next evolution for this species hasn't been defined");
        require(_speciesBreedsTo[species] != 0, "The first evolution on birth for this species hasn't been defined");
        _totalNumPokemon += 1;
        _pokSpeciesId.push(species);
        _pokOwner.push(owner);
        _pokForSale.push(forSale);
        _pokPrice.push(price);
        _pokLevel.push(level);
        _pokCanEvolve.push(false);
        _pokStunned.push(false);
        _pokTimesCanBreed.push(_speciesTimesCanBreed[species]);
        _pokGeneration.push(generation);
        emit PokemonAdded(_totalNumPokemon - 1);
    }

    function _random() internal view returns (uint8) {
        // credit: https://gist.github.com/michielmulders/b14d795a1d2c38af1133ea546fc641bc
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 251);
    }

}