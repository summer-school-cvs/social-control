// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "../IAction.sol";
import "../AllianceStorage.sol";

contract RemoveMember is AllianceStorage, IAction {
    function execute(address candidate) public override {
        require(candidates_for_exclusion[candidate] != address(0), "The address is not on the candidate list.");
        
        candidates_for_exclusion[candidate] = address(0);
        members[candidate].is_member = false;
        members_count -= 1;
        if(members_count == 0) {
            (bool success,) = address(this).
                call(abi.encodeWithSignature("destroy()")); // TODO: msg.sender
            require(success);
        }
    }
}
