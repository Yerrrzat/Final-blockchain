// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CourseToken is ERC20 {
    address public owner;

    constructor() ERC20("Course Reward Token", "CRT") {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Not authorized");
        _mint(to, amount);
    }

    function transferOwnership(address newOwner) external {
    require(msg.sender == owner, "Only current owner can transfer");
    owner = newOwner;
    }
}