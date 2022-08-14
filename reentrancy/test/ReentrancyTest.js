const assert = require('assert');
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

describe("reentrancy attack", function () {
  const provider = waffle.provider;
  let DepositFunds;
  let deployedDepositFunds;
  let Attack;
  let deployedAttack;

  before(async () => {
    DepositFunds = await ethers.getContractFactory("DepositFunds");
    Attack = await ethers.getContractFactory("Attack");
  })

  it("fixed", async function () {  
    
    const [owner, hacker] = await ethers.getSigners();
    //initial balance of owner
    expect(ethers.utils.formatEther((await provider.getBalance(owner.address)))).to.equal("10000.0");

    deployedDepositFunds = await DepositFunds.connect(owner).deploy();
    await deployedDepositFunds.deployed();

    await deployedDepositFunds.deposit({value: ethers.utils.parseEther("5.0")})
    //owner balance in DepositFunds contract after depositing
    expect(await deployedDepositFunds.balances(owner.address)).to.equal("5000000000000000000");

    deployedAttack = await Attack.connect(hacker).deploy(deployedDepositFunds.address);
    await deployedAttack.deployed();
    // starting reentrancy attack by calling attack method of Attack.sol contract
    // await at.attack({value: ethers.utils.parseEther("1.0"), from: hacker.address})
    await expect(deployedAttack.attack({value: ethers.utils.parseEther("1.0"), from: hacker.address})).to.be.reverted
    
    //hacker got all the funds
    // expect(ethers.utils.formatEther(await provider.getBalance(hacker.address))).to.equal('10004.999320902877512092');

    //hacker only got his/her many back - for modifier - 9999.999388578286632722
    expect(ethers.utils.formatEther(await provider.getBalance(hacker.address))).to.equal('9999.999424068661534036');

  });

});