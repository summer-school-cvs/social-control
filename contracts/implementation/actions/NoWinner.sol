// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "../../interface/IAction.sol";
import "../../interface/AllianceStorage.sol";

contract NoWinner is AllianceStorage, IAction {
    function execute(address candidate) public override {
        // members.push(address(0));
        // members.push(address(0));
        // members.push(address(0));
        // members.push(address(0));
    }
}
