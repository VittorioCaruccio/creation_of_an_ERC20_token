//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ourToken is ERC20 {
    //initialSupply amount of token given in the constructor to the creator when the contract will be deployed
    constructor(uint256 initialSupply) ERC20("ourToken", "OT") {
        _mint(msg.sender, initialSupply);
    }
}
