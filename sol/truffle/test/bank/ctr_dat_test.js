const MEDCtr = artifacts.require("MED");
const DATCtr = artifacts.require("DAT");


contract('DAT', async (accounts) => {
 
  let tryCatch = require("../utils/exceptions.js").tryCatch;
  let errTypes = require("../utils/exceptions.js").errTypes;

  let medCtr;
  let centralBankAcc = accounts[0];
  let treasureAcc    = accounts[9];

  let issuingBank    = accounts[8];

  let citizen1    = accounts[1];
  let citizen2    = accounts[2];
  let citizen3    = accounts[3];
  let citizen4    = accounts[4];
  let citizen5    = accounts[5];

  before(async() => {
    medCtr = await MEDCtr.new(treasureAcc, 5, 1000, false, 1000000, {from: centralBankAcc});
  });

  it("Public variable should be set by constructor", async() => {
    let datCtr = await DATCtr.new(1000, 2, 1, medCtr.address, {from: issuingBank});
    let minAm = await datCtr.minimumAmount();
    assert.equal(minAm, 1000, "Minimum amount for the DAT is set");
  });

})