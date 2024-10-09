// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EduToken is ERC20, Ownable {
    
    // Initial supply to be minted on deployment
    uint256 constant INITIAL_SUPPLY = 1000000 * (10 ** 18);

    constructor() ERC20("EduToken", "EDU") {
        // Mint the initial supply to the contract deployer
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // Mint function to allow owner to mint more tokens
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
