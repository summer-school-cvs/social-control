// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./Owned.sol";

abstract contract IAction is Owned {
    function execute(address) public virtual;
}
