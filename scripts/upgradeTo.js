const { ethers, upgrades } = require("hardhat");

async function main() {
  const CharityTokenV2 = await ethers.getContractFactory("CharityTokenV2");
  const upgraded = await upgrades.upgradeProxy(
    "0x7d85C136565c5eb7032AFa247B4AD588b18122F4", // proxy address
    CharityTokenV2
  );

  console.log("[+] The upgrade was successfuly performed !!");

  // quick check
  const CharityTokenV2Proxy = await ethers.getContractAt(
    "CharityTokenV2",
    "0x7d85c136565c5eb7032afa247b4ad588b18122f4" // proxy address
  );
  const versionV2 = await CharityTokenV2Proxy.version();
  console.log(versionV2);
}

main();
