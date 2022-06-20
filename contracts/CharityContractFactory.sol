// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./CharityContract.sol";
import "./CharityToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract CharityContractFactory is Ownable, KeeperCompatibleInterface {
    // this variable store all the compaigns managers with the contract they manage with the amount they have collected until now

    mapping(address => uint256) donorsList;
    mapping(address => address[]) collectorsList; // this variables contain all the collectors (people that create charity contracts with the list of contracts that they manage)

    // charity contract address => charity compain object
    address[] public listOfCharityCompaigns;

    // charity token
    CharityToken public t;

    // checked smart contract delay is a variable that help avoid a DOS attack with keepers, in this variable I store the number of charity contract that have been
    // verified and then the next time when keeper is called again I check the next portion with 10 contract at a time.
    uint256 public lastCheckedSC;

    // fix the DOS attack that can be performed because of the onlyCompain modifier the following mapping is added. it can also be used to keep a track of the amount of money raised or the target amount of the compaign
    mapping(address => uint256) public mappingOfCharityCompaigns;
    // this might cause a DOS attack
    modifier onlyCompaign() {
        /*for (uint256 i = 0; i < listOfCharityCompaigns.length; i++) {
            if (listOfCharityCompaigns[i] == msg.sender) {
                _;
            }
        }*/
        if (mappingOfCharityCompaigns[msg.sender] != 0) {
            _;
        }
    }

    constructor(address _token) {
        t = CharityToken(_token);
    }

    function createCharityContract(address payable beneficiarWallet)
        public
        returns (address)
    {
        // this function will be used to create new contracts
        CharityContract c = new CharityContract(msg.sender, beneficiarWallet);
        collectorsList[msg.sender].push(address(c));
        listOfCharityCompaigns.push(address(c));
        mappingOfCharityCompaigns[address(c)] = 1;
        return address(c);
    }

    function addDonore(address donore, uint256 amount)
        public
        onlyCompaign
        returns (bool)
    {
        // this function can only be executed by the smart contracts created by this factory
        donorsList[donore] += amount;
        return t.transfer(donore, amount * 10); // 10 is just a random value you can modify it if you want that represent the equivalent of wei in terms of charitytokens
    }

    // chainlink keepers required function :
    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory contractAddress)
    {
        // The keeper should send a call every 10 minutes or 1h depending on the
        uint256 i;
        for (
            i = lastCheckedSC;
            i < listOfCharityCompaigns.length && i <= lastCheckedSC + 10; // 10 means 10 smart contract will be checked
            i++
        ) {
            CharityContract c = CharityContract(listOfCharityCompaigns[i]);
            if (c.closingDate() <= block.timestamp && c.stat() != 0) {
                return (true, abi.encode(listOfCharityCompaigns[i], i));
            }
        }
        return (false, abi.encode("", i));
    }

    function performUpkeep(bytes calldata performData) external override {
        /*
            this function will receive the address of the function that should be closed
            and simply call its stop
         */
        (address caddress, uint256 i) = abi.decode(
            performData,
            (address, uint256)
        );
        CharityContract c = CharityContract(caddress); // this is needed to convert the performData to address
        if (i == listOfCharityCompaigns.length - 1) {
            lastCheckedSC = 0;
        } else {
            lastCheckedSC = i;
        }
        c.closeDonation();
    }
}
