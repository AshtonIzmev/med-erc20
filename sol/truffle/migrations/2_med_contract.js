var medCtr = artifacts.require("./MED.sol");

module.exports = function(deployer) {
  deployer.deploy(medCtr, "0xf5af46A7535E03c8b6D7cb6C507C4345fA430785", 5, 1000, false, 1000);
};