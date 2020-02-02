pragma solidity ^0.5.0;

contract Cryptomon {
    address[16] public owner;
    uint[16] public price;

    mapping (address => uint) pendingWithdrawals;

    constructor() public {
        // Creator of contract owns all pokemon
        for (uint8 i = 0; i < owner.length; i++) {
            owner[i] = msg.sender;
        }

        // All pokemon cost 10
        for (uint8 i = 0; i < price.length; i++) {
            price[i] = 10;
        }
    }

    function buyPokemon(uint pokemonId) public payable returns (uint) {
        require(pokemonId >= 0 && pokemonId <= 15, "pokemonId out of bounds");
        require(msg.value > 0, "Payment required");
        require(price[pokemonId] == msg.value, "Wrong payment amount");
        pendingWithdrawals[owner[pokemonId]] += msg.value;
        owner[pokemonId] = msg.sender;
        return pokemonId;
    }

    function getOwners() public view returns (address[16] memory) {
        return owner;
    }

    function getPrices() public view returns (uint[16] memory) {
        return price;
    }

    function withdrawFunds() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}