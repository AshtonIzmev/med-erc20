var medCtr = artifacts.require("./MED.sol");

module.exports = function(deployer) {
  deployer.deploy(medCtr, "0x0000000000000000000000000000000000000000", 5, 1000);
};