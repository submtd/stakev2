// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PairToken is ERC20
{
    constructor() ERC20("Pair Token", "PTKN") {}

    /**
     * Mint.
     * @param to_ Address to mint to.
     * @param amount_ Amount to mint.
     * @dev This is a mock contract so free tokens for everyone!
     */
    function mint(address to_, uint256 amount_) external
    {
        _mint(to_, amount_);
    }
}
