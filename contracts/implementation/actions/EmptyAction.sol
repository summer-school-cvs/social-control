// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "../../interface/IAction.sol";
import "../../interface/AllianceStorage.sol";

contract EmptyAction is AllianceStorage, IAction {
    function execute(address val) public override {
    }
}