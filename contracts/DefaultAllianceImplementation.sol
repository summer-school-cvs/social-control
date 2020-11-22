pragma solidity >=0.5.0;

import "./AllianceStorage.sol";
import "./IAllianceImplementation.sol";

contract DefaultAllianceImplementation is AllianceStorage, IAllianceImplementation {
    function join(address val) public override returns(address) {
        return address(0);
    }
    function exclude(address val) public override  returns(address) {
        return address(0);
    }
    function leave() public override  returns(address) {
        return address(0);
    }
    
    function delegateTo(address val) public override {
    }
    function undelegateFrom(address val) public override {
    }
    
    function updateImplementation(address val) public override returns(address) {
        return address(0);
    }
    
    function processVotingResult(uint256 id) public override {
    }
}
