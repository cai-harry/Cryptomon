pragma solidity >=0.6.1;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Cryptomon.sol";

// contract MockClient {
//     function buy(address cryptomon, address id) public {
//         uint price = cryptomon._pokPrice(id);
//         cryptomon.buyPokemon.value(price)(id);
//     }
// }

contract TestCryptomon {

    // Cryptomon public mon;
    // address payable testCreator;

    // uint public initialBalance = 1 ether;
    // event FundsReceived(address from, uint amount);
    // receive () external payable {
    //     emit FundsReceived(msg.sender, msg.value);
    // }

    // constructor() public {
    //     testCreator = msg.sender;
    // }

    // modifier asAdmin() {
    //     mon = new Cryptomon();

    //     require(mon._admin() == address(this), "Should run this test as admin");
    //     _;
    // }

    // modifier asNormalUser() {
    //     mon = Cryptomon(DeployedAddresses.Cryptomon());
    //     require(mon._admin() != address(this), "Should run this test as not an admin");
    //     _;
    // }

    // function testAddInitialPokemon() public asAdmin() {
    //     uint numAdded = mon.addInitialPokemon();
    //     Assert.isTrue(numAdded > 0, "Failed to add any initial pokemon");
    //     Assert.isTrue(mon._totalNumPokemon() > 0, "Claimed to, but failed to, add any initial pokemon");
    // }

    // function testDefineSpeciesAddPokemon() public asAdmin() {
    //     mon.defineSpecies("Mimikyu", "Dark", "Mimikyu", "Mimikyu", 2);
    //     Assert.equal(mon._speciesType("Mimikyu"), "Dark", "Species type not set correctly");
    //     Assert.equal(mon._speciesEvolvesTo("Mimikyu"), "Mimikyu", "Species evolution not set correctly");
    //     Assert.equal(mon._speciesBreedsTo("Mimikyu"), "Mimikyu", "Species breeding not set correctly");
    //     Assert.equal(uint(mon._speciesTimesCanBreed("Mimikyu")), 2, "Species times can breed not set correctly");
        
        
    //     uint id = mon.addPokemon(
    //         "Mimikyu",
    //         100 finney,
    //         true,
    //         3
    //     );

    //     address newPokemonOwner = mon._pokOwner(id);
    //     Assert.equal(newPokemonOwner, mon._admin(), "Newly created Pokemon should be owned by admin");
    // }

    // function testBuyPokemon() public asNormalUser() {
    //     uint idToBuy = 1;
    //     uint price = mon._pokPrice(idToBuy);
    //     uint id = mon.buyPokemon.value(price)(idToBuy);
    //     Assert.equal(id, idToBuy, "buyPokemon returned different id to what was requested");
    //     Assert.equal(mon._pokOwner(id), address(this), "This contract should own the pokemon after buying");
    // }

    // function testSellPokemon() public asNormalUser() {
    //     uint id = 1;
    //     uint price = 2 ether;
    //     mon.sellPokemon(id, price);
    //     Assert.isTrue(mon._pokForSale(id), "The pokemon wasn't listed for sale");
    //     Assert.equal(mon._pokPrice(id), price, "The pokemon wasn't listed at the correct price");
    // }

    // function testFight() public asNormalUser() {
    //     // TODO: pick uneven fights with certain outcomes, then test winner and loser on evolve and revive
    //     uint id = 1;
    //     uint lvlBefore = mon._pokLevel(id);
    //     bool win = mon.fight(id, 0);
    //     if (win) {
    //         Assert.equal(uint(mon._pokLevel(id)), lvlBefore+1, "Pokemon won but didn't gain a level");
    //     } else {
    //         Assert.isTrue(mon._pokStunned(id), "Pokemon lost but didn't get stunned");
    //     }
    // }

    // // function testEvolve() public asNormalUser() {
    // //     // TODO
    // // }

    // // function testRevive() public asNormalUser() {
    // //     // TODO
    // // }

    // // function testBreed() public asNormalUser() {
    // //     // TODO
    // // }

    // function testWithdrawFunds() public asNormalUser() {
    //     address(mon).transfer(100 finney);
    //     uint pendingBalance = mon.checkBalance();
    //     Assert.isTrue(pendingBalance > 0, "Zero balance in pending withdrawals");
    //     uint balanceBefore = address(this).balance;
    //     uint amount = mon.withdrawFunds();
    //     Assert.equal(amount, pendingBalance, "Returned amount doesn't match pending balance");
    //     uint balanceAfter = address(this).balance;
    //     Assert.equal(amount, balanceAfter-balanceBefore, "Incorrect amount transferred");
    // }

    // function afterAll() public {
    //     testCreator.transfer(address(this).balance);
    // }


}