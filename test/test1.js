const { expect } = require("chai");
const { ethers } = require("hardhat");

// ======================= CharityToken contract tests ==============================

describe("CharityToken", function () {
  let charityToken, charityTokenFactory;
  beforeEach(async function () {
    charityTokenFactory = await ethers.getContractFactory("CharityToken");
    charityToken = await charityTokenFactory.deploy(10000);
  });

  it("Should succesfuly initiat the owner variable and send him 10000 token", async function () {
    const tokenContractOwner = await charityToken.owner();
    const ownerTokensCount = await charityToken.balanceOf(tokenContractOwner);
    expect(ownerTokensCount).to.equal("10000");
  });

  it("Should succesfuly mint new tokens", async function () {
    const tokenContractOwner = await charityToken.owner();
    const ownerTokensCount = await charityToken.balanceOf(tokenContractOwner);
    await charityToken.createTokens(9999);
    expect(await charityToken.balanceOf(tokenContractOwner)).to.equal("19999");
  });
});
