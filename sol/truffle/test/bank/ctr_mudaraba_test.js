const MEDCtr = artifacts.require("MED");
const FPCtr = artifacts.require("FP");
const MudarabaCtr = artifacts.require("Mudaraba");


contract('Mudaraba', async (accounts) => {
 
  let tryCatch = require("../utils/exceptions.js").tryCatch;
  let errTypes = require("../utils/exceptions.js").errTypes;

  let medCtr;
  let mudarabaCtr;
  let fpCtr;
  let centralBankAcc = accounts[0];
  let treasureAcc    = accounts[9];

  let issuingBank    = accounts[8];

  let citizen1    = accounts[1];
  let citizen2    = accounts[2];
  let citizen3    = accounts[3];
  let citizen4    = accounts[4];
  let citizen5    = accounts[5];

  before(async() => {
    medCtr = await MEDCtr.new(treasureAcc, 5, 10000, false, 10000000, {from: centralBankAcc});
    fpCtr = await FPCtr.new("Financial Products NFT", "FPNFT", {from: issuingBank});
    let desc = "Description";
    mudarabaCtr = await MudarabaCtr.new(desc, "1234567", 10000, medCtr.address, fpCtr.address, {from: citizen1});
    await fpCtr.setApprovalForAll(mudarabaCtr.address, true, {from: citizen1});
    await medCtr.incrementMonth({from: centralBankAcc});
    await medCtr.incrementMonth({from: centralBankAcc});
    await medCtr.updateAccount(citizen2, {from: citizen1});
    await medCtr.updateAccount(citizen3, {from: citizen1});
  });

  it("Public variables should be set by constructor", async() => {
    let desc = "Description";
    let tmpMudarabaCtr = await MudarabaCtr.new(desc, "12345", 10000, medCtr.address, fpCtr.address, {from: citizen1});
    let description = await tmpMudarabaCtr.description();
    let ice = await tmpMudarabaCtr.ice();
    let capitalCap = await tmpMudarabaCtr.capitalCap();
    assert.equal(description, desc, "Description is set");
    assert.equal(ice, 12345, "ICE is set");
    assert.equal(capitalCap, 10000, "Capital Cap is set");
  });

})