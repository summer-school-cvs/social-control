// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "../../interface/IAction.sol";
import "../../interface/AllianceStorage.sol";

contract AddMember is AllianceStorage, IAction {
    function execute(address candidate) public override {
        require(candidates_for_membership[candidate] != address(0), "The address is not on the candidate list.");
        
        candidates_for_membership[candidate] = address(0);
        members_info[candidate].is_member = true;
        members_info[candidate].index = members.length;
        members.push(candidate);
    }
}
