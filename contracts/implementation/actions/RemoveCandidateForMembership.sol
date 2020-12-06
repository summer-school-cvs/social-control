// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "../../interface/IAction.sol";
import "../../interface/AllianceStorage.sol";

contract RemoveCandidateForMembership is AllianceStorage, IAction {
    function execute(address candidate) public override {
        candidates_for_membership[candidate] = address(0);
    }
}
