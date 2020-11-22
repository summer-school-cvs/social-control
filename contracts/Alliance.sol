pragma solidity >=0.5.0;

import "./AllianceStorage.sol";
import "./IAllianceImplementation.sol";
import "./DefaultAllianceImplementation.sol";
import "./actions/AddMember.sol";
import "./actions/EmptyAction.sol";

contract Alliance is AllianceStorage, IAllianceImplementation {
    constructor() public {
        implementation = new DefaultAllianceImplementation();
        members[msg.sender].is_member = true;
        member_add_action = new AddMember();
        empty_action = new EmptyAction();
    }
    
    function join(address val) public override returns(address) {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("join(address)", val));
        if(success) {
        }
        
        return abi.decode(result, (address));
    }
    function exclude(address val) public override  returns(address) {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("exclude(address)", val));
        if(success) {
        }
        
        return abi.decode(result, (address));
    }
    function leave() public override  returns(address) {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("leave()"));
        if(success) {
        }
        
        return abi.decode(result, (address));
    }
    
    function delegateTo(address val) public override {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("delegateTo(address)", val));
        if(success) {
        }
    }
    function undelegateFrom(address val) public override {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("undelegateFrom(address)", val));
        if(success) {
        }
    }
    
    function updateImplementation(address val) public override returns(address) {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("updateImplementation(address)", val));
        if(success) {
        }
        
        return abi.decode(result, (address));
    }
    
    function processVotingResult(uint256 id) public override {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("processVotingResult(uint256)", id));
        if(success) {
        }
    }
}
