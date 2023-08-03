// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";

contract TaxHandler is BaseContract
{
    /**
     * Contract constructor.
     * @param registry_ Registry address.
     */
    constructor(address registry_) BaseContract(registry_) {}

    /**
     * Distribute taxes.
     */
    function distribute() external
    {
        // TODO
    }
}