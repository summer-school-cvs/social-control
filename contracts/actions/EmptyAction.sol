pragma solidity >=0.5.0;

import "../IAction.sol";
import "../AllianceStorage.sol";

contract EmptyAction is AllianceStorage, IAction {
    function execute(address val) public override {
    }
}