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

    Cryptomon public mon;
    address payable testCreator;

    uint public initialBalance = 1 ether;
    event FundsReceived(address from, uint amount);
    receive () external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    constructor() public {
        testCreator = msg.sender;
    }

    modifier asAdmin() {
        mon = new Cryptomon();
        require(mon._admin() == address(this));
        _;
    }

    modifier asNormalUser() {
        mon = Cryptomon(DeployedAddresses.Cryptomon());
        require(mon._admin() != address(this));
        _;
    }

    function testConstructor() public asAdmin() {
        address admin = mon._admin();

        Assert.equal(admin, address(this), "Admin should be the contract creator");
    }

    function testAddPokemon() public asAdmin() {
        uint id = mon.addPokemon(
            "Mimikyu",
            "Fairy",
            0.1 ether,
            3,
            "Mimikyu",
            2,
            "Mimikyu"
        );

        address newPokemonOwner = mon._pokOwner(id);
        Assert.equal(newPokemonOwner, mon._admin(), "Newly created Pokemon should be owned by admin");
    }

    function testBuyPokemon() public asNormalUser() {
        uint idToBuy = 1;
        uint price = mon._pokPrice(idToBuy);
        uint id = mon.buyPokemon.value(price)(idToBuy);
        Assert.equal(id, idToBuy, "buyPokemon returned different id to what was requested");
        Assert.equal(mon._pokOwner(id), address(this), "This contract should own the pokemon after buying");
    }

    function testSellPokemon() public asNormalUser() {
        uint id = 1;
        uint price = 2 ether;
        mon.sellPokemon(id, price);
        Assert.isTrue(mon._pokForSale(id), "The pokemon wasn't listed for sale");
        Assert.equal(mon._pokPrice(id), price, "The pokemon wasn't listed at the correct price");
    }

    function testWithdrawFunds() public asNormalUser() {
        address(mon).transfer(0.1 ether);
        uint pendingBalance = mon.checkBalance();
        Assert.isTrue(pendingBalance > 0, "Zero balance in pending withdrawals");
        uint balanceBefore = address(this).balance;
        uint amount = mon.withdrawFunds();
        Assert.equal(amount, pendingBalance, "Returned amount doesn't match pending balance");
        uint balanceAfter = address(this).balance;
        Assert.equal(amount, balanceAfter-balanceBefore, "Incorrect amount transferred");
    }

    function afterAll() public {
        testCreator.transfer(address(this).balance);
    }


}