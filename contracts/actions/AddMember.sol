pragma solidity >=0.5.0;

import "../IAction.sol";
import "../AllianceStorage.sol";

contract AddMember is AllianceStorage, IAction {
    function execute(address val) public override {
        // address new_member;          // TODO: new_member from won proposal
        // address[] memory supportive; // TODO: supportive from voting
        // members[new_member].is_member = true;
        // members[new_member].supportive = supportive;
    }
}
