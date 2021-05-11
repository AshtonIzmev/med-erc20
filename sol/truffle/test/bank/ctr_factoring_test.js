const MEDCtr = artifacts.require("MED");
const FPCtr = artifacts.require("FP");
const FactoringCtr = artifacts.require("Factoring");


contract('DAT', async (accounts) => {
 
  let tryCatch = require("../utils/exceptions.js").tryCatch;
  let errTypes = require("../utils/exceptions.js").errTypes;

  let medCtr;
  let factoringCtr;
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
    factoringCtr = await FactoringCtr.new(medCtr.address, fpCtr.address, {from: citizen1});
    await fpCtr.setApprovalForAll(factoringCtr.address, true, {from: citizen1});
    await medCtr.incrementMonth({from: centralBankAcc});
    await medCtr.incrementMonth({from: centralBankAcc});
    await medCtr.updateAccount(citizen2, {from: citizen1});
    await medCtr.updateAccount(citizen3, {from: citizen1});
  });

})