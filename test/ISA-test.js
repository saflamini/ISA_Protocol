const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");


describe("ISA Deploys Correctly", function () {
    it("Should set correct values in the constructor", async function () {
      const [acct1, acct2, acct3] = await ethers.getSigners();
      const ISA = await ethers.getContractFactory("ISA");
      const isa = await ISA.deploy(
        "0xEB796bdb90fFA0f28255275e16936D25d3418603",
        "0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873",
        "0x5D8B4C2554aeB7e86F387B4d6c00Ac33499Ed01f",
        BigNumber.from("100000000000000000000"), //100
        1000, // 10 percent
        94608000, //3 years
        BigNumber.from("100000000000000000000000"), //10000
        15811200 //6 months

      );
      await isa.deployed();
    //   let payDestination;
    //   let stakeRequirement;
    //   let repaymentPercent;
    //   let repaymentPeriodLength;
    //   let maxRepaymentAmount;
    //   let gracePeriod;
      
      const ISAInfo = await isa.getAgreementInfo();
      
      const [payDestination, stakeRequirement, repaymentPercent, repaymentPeriodLength, maxRepaymentAmount, gracePeriod] = ISAInfo;

      console.log(`Pay Destination Address: ${payDestination}`);
      console.log(`Stake Requirement: ${stakeRequirement}`);
      console.log(`Repayment Percent: ${repaymentPercent}`);
      console.log(`Repayment Period Length: ${repaymentPeriodLength}`);
      console.log(`Max Repayment Amount: ${maxRepaymentAmount}`);
      console.log(`Grace Period: ${gracePeriod}`);

  
      expect(payDestination).to.equal(acct1.address);
      expect(stakeRequirement).to.equal(BigNumber.from("100000000000000000000"));
      expect(repaymentPercent).to.equal(1000);
      expect(repaymentPeriodLength).to.equal(94608000);
      expect(maxRepaymentAmount).to.equal(BigNumber.from("100000000000000000000000"));
      expect(gracePeriod).to.equal(15811200);
    });


  });
  