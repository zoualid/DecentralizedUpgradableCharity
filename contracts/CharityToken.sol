// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CharityToken is Initializable, ERC20Upgradeable {
    address public owner;

    modifier onlyOwner() {
        if (msg.sender == owner) _;
    }

    /*constructor(uint256 amount) ERC20("Charity Token", "CT") {
        owner = msg.sender;
        _mint(owner, amount);
    }*/

    function initialize(address tokenOwner, uint256 amount)
        external
        initializer
    {
        __ERC20_init("Charity Token", "CT");
        owner = tokenOwner;
        _mint(owner, amount);
    }

    function createTokens(uint256 amount) public onlyOwner returns (bool) {
        _mint(owner, amount);
        return true;
    }
}
