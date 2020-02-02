pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Cryptomon.sol";

contract TestCryptomon {
    uint public initialBalance = 100;

    // The address of the adoption contract to be tested
    Cryptomon cryptomon = Cryptomon(DeployedAddresses.Cryptomon());

    uint256 expectedPokemonId = 8;

    address expectedOwner = address(this);

    function testBuyPokemon() public {
        uint price = cryptomon.price(expectedPokemonId);
        uint256 returnedId = cryptomon.buyPokemon.value(price)(expectedPokemonId);
        Assert.equal(
            returnedId,
            expectedPokemonId,
            "Id of requested pokemon should match what is returned."
        );
    }

    // Testing retrieval of a single pokemon's owner
    function testGetOwnerByPokemonId() public {
        address owner = cryptomon.owner(expectedPokemonId);

        Assert.equal(
            owner,
            expectedOwner,
            "Owner of the requested pokemon should be this contract"
        );
    }

    // Testing retrieval of all pokemon owners
    function testGetOwnerByPokemonIdInArray() public {
        // Store adopters in memory rather than contract's storage
        address[16] memory owners = cryptomon.getOwners();

        Assert.equal(
            owners[expectedPokemonId],
            expectedOwner,
            "Owner of the requested pokemon should be this contract"
        );
    }

    // TODO: testWithdrawFunds()

}
