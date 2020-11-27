// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "../IAction.sol";
import "../AllianceStorage.sol";

contract ExcludeMember is AllianceStorage, IAction {
    function execute(address candidate) public override {
        require(
            candidates_for_exclusion[candidate] != address(0),
            "The address is not on the candidate list."
        );

        candidates_for_exclusion[candidate] = address(0);
        members[candidate].is_member = false;
        // TODO: supportive from election
        // members[new_member].supportive = supportive;
    }
}
