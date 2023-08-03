// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Vault is BaseContract, ERC721, ERC721Enumerable
{
    /**
     * Contract constructor.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     * @param registry_ Registry address.
     */
    constructor(string memory name_, string memory symbol_, address registry_)
        BaseContract(registry_)
        ERC721(name_, symbol_)
    {}
}