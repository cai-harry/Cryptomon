var Cryptomon = artifacts.require("./Cryptomon.sol");

module.exports = function(deployer) {
  deployer.deploy(Cryptomon);
};