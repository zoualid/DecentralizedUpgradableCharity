// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CharityToken is ERC20 {
    address public owner;

    modifier onlyOwner() {
        if (msg.sender == owner) _;
    }

    constructor(uint256 amount) ERC20("Charity Token", "CT") {
        owner = msg.sender;
        _mint(owner, amount);
    }

    function createTokens(uint256 amount) public onlyOwner returns (bool) {
        _mint(owner, amount);
        return true;
    }
}
