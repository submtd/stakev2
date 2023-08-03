// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

error ContractHasAlreadyBeenSet(string name_, address address_);
error ContractAddressCannotBeEmpty();
error ContractDoesNotExist();

contract Registry is Ownable {
    /**
     * Contracts registry.
     */
    mapping(string => address) private _contracts;

    /**
     * Add contract to registry.
     * @param name_ Contract name.
     * @param contractAddress_ Contract address.
     */
    function addContract(string memory name_, address contractAddress_) public onlyOwner {
        if(_contracts[name_] != address(0)) revert ContractHasAlreadyBeenSet(name_, _contracts[name_]);
        if(contractAddress_ == address(0)) revert ContractAddressCannotBeEmpty();
        _contracts[name_] = contractAddress_;
    }

    /**
     * Get contract address.
     * @param name_ Contract name.
     * @return Contract address.
     */
    function getContract(string memory name_) public view returns (address) {
        if(_contracts[name_] == address(0)) revert ContractDoesNotExist();
        return _contracts[name_];
    }
}
