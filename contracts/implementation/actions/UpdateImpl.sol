// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "../../interface/IAction.sol";
import "../../interface/AllianceStorage.sol";

contract UpdateImpl is AllianceStorage, IAction {
    function execute(address new_impl) public override {
        IAlliance new_alliance_impl = IAlliance(new_impl);
        require(new_alliance_impl != IAlliance(0));
        IAlliance last = implementation;
        implementation = new_alliance_impl;
        if(last != IAlliance(0))
            last.destroy();
    }
}