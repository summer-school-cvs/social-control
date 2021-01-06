// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "../../interface/IAction.sol";
import "../../interface/AllianceStorage.sol";

contract RemoveMember is AllianceStorage, IAction {
    function execute(address candidate) public override {
        if(members.length == 1) {
            (bool success,) = address(this).
                delegatecall(abi.encodeWithSignature("destroy()"));
            require(success);
        }
        else {
            require(candidates_for_exclusion[candidate] != address(0), "The address is not on the candidate list.");

            uint256 exluded_index = members_info[candidate].index;
            uint256 last_index = members.length - 1;
            address moved_item = members[last_index];

            candidates_for_exclusion[candidate] = address(0);

            members_info[candidate].is_member = false;
            members[exluded_index] = moved_item;
            members_info[moved_item].index = exluded_index;
            members.pop();
        }
    }
}
