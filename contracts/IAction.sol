// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./Election.sol";

abstract contract IAction  {
    function execute(address) public virtual;
}
