pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Cryptomon.sol";

contract TestCryptomon {
    function testConstructor() public {
        Cryptomon mon = Cryptomon(DeployedAddresses.Cryptomon());

        address admin = mon._admin();

        Assert.equal(admin, address(this), "Admin should be the contract creator");
    }

    function testAddPokemon() public {
        // Cryptomon mon = Cryptomon(DeployedAddresses.Cryptomon());
        Cryptomon mon = new Cryptomon();

        uint id = mon.addPokemon(
            "Mimikyu",
            "Fairy",
            1 ether,
            3,
            "Mimikyu",
            2,
            "Mimikyu"
        );

        address newPokemonOwner = mon._pokOwner(id);
        Assert.equal(newPokemonOwner, mon._admin(), "Newly created Pokemon should be owned by admin");
    }
}