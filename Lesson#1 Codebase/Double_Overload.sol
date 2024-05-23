// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Contract {
    // Original double function, now public
    function double(uint x) public pure returns (uint) {
        return x * 2;
    }

    // Overloaded double function that takes two parameters
    function double(uint x, uint y) external pure returns (uint, uint) {
        return (x * 2, y * 2);
    }
}
