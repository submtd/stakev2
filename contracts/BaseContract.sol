// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRegistry
{
    function getContract(string memory name_) external view returns (address);
}

contract BaseContract
{

    /**
     * Contracts registry.
     */
    IRegistry private _registry;

    /**
     * Addresses.
     */
    mapping(string => address) private _addresses;

    /**
     * Contract constructor.
     * @param registry_ Registry address.
     */
    constructor(address registry_)
    {
        _registry = IRegistry(registry_);
    }

    /**
     * Get contract address.
     * @param name_ Contract name.
     * @return Contract address.
     */
    function _getContract(string memory name_) internal returns (address)
    {
        if(_addresses[name_] == address(0)) _addresses[name_] = _registry.getContract(name_);
        return _addresses[name_];
    }

    /**
     * Get contract address (read only).
     * @param name_ Contract name.
     * @return Contract address.
     */
    function _getContractReadOnly(string memory name_) internal view returns (address)
    {
        return _registry.getContract(name_);
    }

}
