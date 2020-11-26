pragma solidity >=0.5.0;

import "../IAction.sol";
import "../AllianceStorage.sol";

contract RemoveCandidateForMembership is AllianceStorage, IAction {
    function execute(address candidate) public override {
        candidates_for_membership[candidate] = address(0);
    }
}
