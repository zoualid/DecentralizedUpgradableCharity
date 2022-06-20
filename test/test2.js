const { expect } = require("chai");
const { ethers } = require("hardhat");

// ======================= CharityContractFactory contract tests ==============================

describe("CharityContractFactory", function () {
  let charityToken, charityTokenFactory;
  let charityContractFactory, charityContractFactoryFactory;
  let charityContract, charityFactory;
  let owner, account1, account2;
  beforeEach(async function () {
    // create accounts
    [owner, account1, account2] = await ethers.getSigners();

    // deploy charitytoken contract
    charityTokenFactory = await ethers.getContractFactory("CharityToken");
    charityToken = await charityTokenFactory.deploy(10000000);

    // deploy charityContractFactory contract
    charityContractFactoryFactory = await ethers.getContractFactory(
      "CharityContractFactory"
    );
    charityContractFactory = await charityContractFactoryFactory.deploy(
      charityToken.address
    );
  });
  it("Should create a new compaign", async function () {
    const tx = await charityContractFactory.createCharityContract(
      account1.address
    );

    const newCompaignAddress =
      await charityContractFactory.listOfCharityCompaigns(0);
    /*console.log("newCompaignAddress : " + newCompaignAddress);
    console.log("New compaign address : " + newCompaignAddress.toString());
    console.log("Charity token address : " + charityToken.address);
    console.log(
      "Charity contract factory address : " + charityContractFactory.address
    );
    console.log(
      "Account 1 or charity contract manager address : " + account1.address
    );*/

    charityC = await ethers.getContractFactory("CharityContract");
    newCompaign = await ethers.getContractAt(
      "CharityContract",
      newCompaignAddress.toString()
    );

    describe("CharityContract setting", function () {
      beforeEach(async function () {
        await newCompaign.setName("compaign1");
        await newCompaign.setDescription("First charity compagne");
        await newCompaign.setTargetFunds(100000);
        await newCompaign.openDonation();
        await newCompaign.setMinDonation(10);
      });
      it("Should set the compaign name", async function () {
        expect(await newCompaign.name()).to.equal("compaign1");
      });
      it("Should set the compaign description", async function () {
        expect(await newCompaign.description()).to.equal(
          "First charity compagne"
        );
      });
      it("Should set the compaign target funds", async function () {
        expect(await newCompaign.targetFunds()).to.equal(100000);
      });
      it("Should set the compaign stat", async function () {
        expect(await newCompaign.stat()).to.equal(1);
      });
      it("Should set the compaign minimum donation", async function () {
        expect(await newCompaign.minDonation()).to.equal(10);
      });
    });

    describe("CharityContract donation", function () {
      beforeEach(async function () {
        await charityToken.transfer(charityContractFactory.address, 90000);
        await newCompaign.donate({
          value: ethers.utils.parseEther("0.00000000000000002"),
        });
      });
      it("Should check if the owner is a donor and has successfully donated 20 wei", async function () {
        expect(await newCompaign.getDonorBalance(owner.address)).to.equal("20");
      });
      it("it checks if other people could participate", async function () {
        await newCompaign.connect(account2).donate({
          value: ethers.utils.parseEther("0.00000000000000003"),
        });
        expect(await newCompaign.getDonorBalance(account2.address)).to.equal(
          "30"
        );
      });
      it("it checks if the donor have received CT tokens after participating", async function () {
        expect(await charityToken.balanceOf(account2.address)).to.equal("300");
      });
    });

    //console.log(await charityContractFactory.callStatic.getLenght());

    //console.log(owner.address);
  });
});
