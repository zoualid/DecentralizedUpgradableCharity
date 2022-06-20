// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./CharityContractFactory.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/*
The ownable smart contract cannot be used here because onlyAdmin does not represents the msg.sender 
but represent an address that the msg.sender choose while creating the smart contract
 */
contract CharityContract is ReentrancyGuard {
    address public admin; // is the manager of this contract
    uint256 public targetFunds;
    uint256 public openingDate;
    uint256 public closingDate;
    uint256 public totalFunds;
    uint256 public minDonation; // in ether
    uint256 public stat;
    address payable immutable beneficiariesWallet;
    address payable public adminFactory; // is the admin of the parent contract charityContractFactory
    CharityContractFactory public co;
    string public name = "test01"; // name of the compaign
    string public description; // descirption of the compaign

    mapping(address => uint256) donors;

    modifier onlyAdmin() {
        if (msg.sender == admin) _;
    }

    modifier onlyManager() {
        if (msg.sender == adminFactory || msg.sender == admin) _;
    }

    constructor(address manager, address payable wallet) {
        admin = manager;
        adminFactory = payable(msg.sender);
        beneficiariesWallet = wallet;
        co = CharityContractFactory(msg.sender);
    }

    function setName(string memory _name) public onlyAdmin {
        name = _name;
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function setDescription(string memory _description) public onlyAdmin {
        description = _description;
    }

    function setTargetFunds(uint256 amount) public onlyAdmin returns (bool) {
        targetFunds = amount;
    }

    function openDonation() public onlyAdmin returns (bool) {
        openingDate = block.timestamp;
        stat = 1; // open for donations
    }

    function donate() public payable returns (bool) {
        // to donate the donor should send a minimum amount of ethers specified by the admin
        require(
            msg.value >= minDonation,
            string(
                abi.encodePacked(
                    "Sorry but the minimum amount of donation in wei is",
                    minDonation
                )
            )
        );
        donors[msg.sender] += msg.value;
        require(
            co.addDonore(msg.sender, msg.value),
            "Donore not added in factory"
        );
        return true;
    }

    // this function will use keepers to check if closing date has arrived to close the funding
    function closeDonation() public onlyManager returns (bool) {
        stat = 0; // 0 represent the stat closed. 1 is opened
        closingDate = block.timestamp;
        return true;
    }

    function setMinDonation(uint256 amount) public {
        minDonation = amount; // in wei
    }

    function getDonorBalance(address donor) public view returns (uint256) {
        return donors[donor];
    }

    function withdrawAll() public onlyAdmin nonReentrant returns (bool) {
        // this function help the admin retrieve all the fundings after the donation process has ended
        // send all money to the beneficiariesWallet
        // this contract should send 1% of its funds to the factory contract so that it can manage newer charity compaigns
        adminFactory.transfer((address(this).balance * 1) / 100);
        beneficiariesWallet.transfer(
            address(this).balance - (address(this).balance * 1) / 100
        );
        return true;
    }

    function destroyContract() public onlyAdmin returns (bool) {
        selfdestruct(beneficiariesWallet);
    }
}
