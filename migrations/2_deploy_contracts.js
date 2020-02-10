var Cryptomon = artifacts.require("./Cryptomon.sol");

module.exports = async function(deployer) {
  await deployer.deploy(Cryptomon);
  let crt = await Cryptomon.deployed();
  await crt.addInitialPokemon();
};