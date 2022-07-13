/*
This script allows you to deploy a the charityToken smart contract with its proxy
*/

const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

const PERSONAL_RINKEBY_ADDRESS = process.env.PERSONAL_RINKEBY_ADDRESS;

async function main() {
  const CharityToken = await ethers.getContractFactory("CharityToken");
  const CharityToken_proxy = await upgrades.deployProxy(CharityToken, [
    PERSONAL_RINKEBY_ADDRESS,
    10000,
  ]);
  await CharityToken_proxy.deployed();

  console.log(
    "Charity token proxy deployed at address: " + CharityToken_proxy.address
  );

  const CharityContractFactory = await ethers.getContractFactory(
    "CharityContractFactory"
  );
  const CharityContractFactory_proxy = await upgrades.deployProxy(
    CharityContractFactory,
    [CharityToken_proxy.address]
  );
  await CharityContractFactory_proxy.deployed();

  console.log(
    "Charity contract factory proxy deployed at address: " +
      CharityContractFactory_proxy.address
  );
}

main();
