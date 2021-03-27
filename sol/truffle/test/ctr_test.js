const MEDCtr = artifacts.require("MED");

contract('MED', async (accounts) => {
 
  let tryCatch = require("./exceptions.js").tryCatch;
  let errTypes = require("./exceptions.js").errTypes;

  let emptyMedCtr;
  let centralBankAcc = accounts[0];
  let treasureAcc    = accounts[9];

  let citizen1    = accounts[1];
  let citizen2    = accounts[2];
  let citizen3    = accounts[3];
  let citizen4    = accounts[4];
  let citizen5    = accounts[5];
  let citizen6    = accounts[6];

  before(async() => {

  });

  it("Name and symbol should be correct", async() => {
    emptyMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    let name = await emptyMedCtr.name();
    let symbol = await emptyMedCtr.symbol();
    assert.equal(name, "Moroccan E-Dirham", "Name should be correct");
    assert.equal(symbol, "MED", "Symbol should be correct");
  });

  it("should make the creator of the contract the owner", async() => {
    emptyMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    let centralBankBalance = await emptyMedCtr.balanceOf(centralBankAcc);
    let treasureBalance = await emptyMedCtr.balanceOf(treasureAcc);
    assert.equal(centralBankBalance, 0, "No money on centralBank account");
    assert.equal(treasureBalance, 0, "No money yet on treasure reserve account");
  });

  it("Only central bank should be allowed to mint and burn", async() => {
    emptyMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    await tryCatch(emptyMedCtr.mint(100, {from: treasureAcc}), errTypes.revert);
    await tryCatch(emptyMedCtr.burn(100, {from: treasureAcc}), errTypes.revert);
    await tryCatch(emptyMedCtr.mint(100, {from: citizen1}), errTypes.revert);
  });

  it("Can't burn money if total supply is empty", async() => {
    emptyMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    await tryCatch(emptyMedCtr.burn(100, {from: centralBankAcc}), errTypes.revert);
  });

  it("Can't burn money if total supply is less than amount to burn", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    await tmpMedCtr.mint(99, {from: centralBankAcc});
    await tryCatch(tmpMedCtr.burn(100, {from: centralBankAcc}), errTypes.revert);
  });

  it("Mint then burn work properly", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    let totalSupply1 = await tmpMedCtr.totalSupply();
    assert.equal(totalSupply1, 0, "Total supply should be 0 at the begining");
    await tmpMedCtr.mint(99, {from: centralBankAcc});
    let totalSupply2 = await tmpMedCtr.totalSupply();
    assert.equal(totalSupply2, 99, "Mint did not work properly");
    await tmpMedCtr.burn(97, {from: centralBankAcc});
    let totalSupply3 = await tmpMedCtr.totalSupply();
    assert.equal(totalSupply3, 2, "Burn did not work properly");
  });

  it("Non central bank cannot mint nor burn", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    tryCatch(tmpMedCtr.mint(100, {from: treasureAcc}), errTypes.revert);
    tryCatch(tmpMedCtr.mint(100, {from: citizen1}), errTypes.revert);
    await tmpMedCtr.mint(99, {from: centralBankAcc});
    tryCatch(tmpMedCtr.burn(50, {from: treasureAcc}), errTypes.revert);
    tryCatch(tmpMedCtr.burn(50, {from: citizen1}), errTypes.revert);
  });

  it("Transfer is working properly", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    await tmpMedCtr.mint(100, {from: centralBankAcc});

    await tmpMedCtr.transfer(citizen1, 10, {from: treasureAcc});
    await tmpMedCtr.transfer(citizen3, 15, {from: treasureAcc});
    await tmpMedCtr.transfer(citizen5, 20, {from: treasureAcc});

    let bal1 = await tmpMedCtr.balanceOf(citizen1);
    let bal2 = await tmpMedCtr.balanceOf(citizen2);
    let bal3 = await tmpMedCtr.balanceOf(citizen3);
    assert.equal(bal1, 10, "Amount has been transfered");
    assert.equal(bal2, 0, "No transfer has occured");
    assert.equal(bal3, 15, "Amount has been transfered");
    let totalSupply = await tmpMedCtr.totalSupply();
    assert.equal(totalSupply, 100, "Total supply does not change with transfer");
  });

  it("Can't transfer more than you have", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 100, {from: centralBankAcc});
    await tmpMedCtr.mint(100, {from: centralBankAcc});

    await tmpMedCtr.transfer(citizen1, 10, {from: treasureAcc});

    await tmpMedCtr.transfer(citizen2, 5, {from: citizen1});
    await tmpMedCtr.transfer(citizen3, 5, {from: citizen1});
    tryCatch(tmpMedCtr.transfer(citizen4, 5, {from: citizen1}), errTypes.revert);

    let bal1 = await tmpMedCtr.balanceOf(citizen1);
    let bal2 = await tmpMedCtr.balanceOf(citizen2);
    let bal3 = await tmpMedCtr.balanceOf(citizen3);
    assert.equal(bal1, 0, "Citizen 1 balance is now empty");
    assert.equal(bal2, 5, "No transfer has ever occured to citizen 2");
    assert.equal(bal3, 5, "Amount has been transfered to citizen 3");
  });

  it("Tax after two days", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 136, {from: centralBankAcc});
    await tmpMedCtr.mint(8000, {from: centralBankAcc});
    await tmpMedCtr.transfer(citizen1, 3700, {from: treasureAcc});
    await tmpMedCtr.transfer(citizen2, 3600, {from: treasureAcc});

    // Two days after ...
    await tmpMedCtr.sleep({from: centralBankAcc});
    await tmpMedCtr.sleep({from: centralBankAcc});

    await tmpMedCtr.transfer(citizen5, 20, {from: citizen1});
    await tmpMedCtr.transfer(citizen6, 20, {from: citizen2});

    let bal1 = await tmpMedCtr.balanceOf(citizen1);
    let bal2 = await tmpMedCtr.balanceOf(citizen2);
    let bal5 = await tmpMedCtr.balanceOf(citizen5);
    let bal6 = await tmpMedCtr.balanceOf(citizen6);
    let balTreasure = await tmpMedCtr.balanceOf(treasureAcc);
    assert.equal(bal1, 3679, "1 e-dh of tax taken");
    assert.equal(bal2, 3580, "No e-dh of tax taken since it was rounded to 0");
    assert.equal(bal5, 20, "Transfer correct");
    assert.equal(bal6, 20, "Transfer correct");
    assert.equal(balTreasure, 701, "1 e-dh of tax added");
  });

  it("No taxation twice in a day", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 136, {from: centralBankAcc});
    await tmpMedCtr.mint(50000, {from: centralBankAcc});
    await tmpMedCtr.transfer(citizen1, 20000, {from: treasureAcc});

    await tmpMedCtr.transfer(citizen5, 20, {from: citizen1});
    let bal1_1 = await tmpMedCtr.balanceOf(citizen1);

    // Two days after ...
    await tmpMedCtr.sleep({from: centralBankAcc});
    await tmpMedCtr.sleep({from: centralBankAcc});

    await tmpMedCtr.transfer(citizen5, 20, {from: citizen1});
    let bal1_2 = await tmpMedCtr.balanceOf(citizen1);

    await tmpMedCtr.transfer(citizen5, 20, {from: citizen1});
    let bal1_3 = await tmpMedCtr.balanceOf(citizen1);

    let balTreasure = await tmpMedCtr.balanceOf(treasureAcc);
    assert.equal(bal1_1, 19980, "No tax taken");
    assert.equal(bal1_2, 19955, "5 e-dh of tax taken");
    assert.equal(bal1_3, 19935, "No tax taken");
    assert.equal(balTreasure, 30005, "5 e-dh of tax added");
  });

  it("Central Bank force taxation", async() => {
    tmpMedCtr = await MEDCtr.new(treasureAcc, 136, {from: centralBankAcc});
    await tmpMedCtr.mint(50000, {from: centralBankAcc});
    await tmpMedCtr.transfer(citizen1, 20000, {from: treasureAcc});

    let bal1_1 = await tmpMedCtr.balanceOf(citizen1);

    // Two days after ...
    await tmpMedCtr.sleep({from: centralBankAcc});
    await tmpMedCtr.sleep({from: centralBankAcc});

    await tmpMedCtr.tax(citizen1, {from: centralBankAcc});
    let bal1_2 = await tmpMedCtr.balanceOf(citizen1);

    let balTreasure = await tmpMedCtr.balanceOf(treasureAcc);
    assert.equal(bal1_1, 20000, "Initial account");
    assert.equal(bal1_2, 19995, "5 e-dh of tax taken");
    assert.equal(balTreasure, 30005, "5 e-dh of tax added");
  });

})