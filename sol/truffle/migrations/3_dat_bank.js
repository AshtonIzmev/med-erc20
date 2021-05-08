var datCtr = artifacts.require("./bank/DAT.sol");

module.exports = function(deployer) {
  deployer.deploy(datCtr, 1000, 10, 1, "0xf5af46A7535E03c8b6D7cb6C507C4345fA430785");
};