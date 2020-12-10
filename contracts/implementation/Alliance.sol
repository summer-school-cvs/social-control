// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "../interface/AllianceStorage.sol";
import "../interface/IAlliance.sol";
import "./DefaultAllianceImplementation.sol";
import "./actions/AddMember.sol";
import "./actions/EmptyAction.sol";
import "./actions/RemoveCandidateForMembership.sol";
import "./actions/RemoveMember.sol";
import "./actions/UpdateImpl.sol";

contract Alliance is AllianceStorage, IAlliance {
    constructor() {
        implementation = new DefaultAllianceImplementation();
        members[msg.sender].is_member = true;
        
        cancel_membership_action = new RemoveCandidateForMembership();
        cancel_exclusion_action = new EmptyAction(); // TODO
        member_add_action = new AddMember();
        member_exclude_action = new RemoveMember();
        member_leave_action = new RemoveMember();
        empty_action = new EmptyAction();
        update_impl_action = new UpdateImpl();
    }
    
    function join(address val) public override returns(address) {
        (bool success, bytes memory result) = address(implementation).
            delegatecall(abi.encodeWithSignature("join(address)", val));
        require(success);        
        return abi.decode(result, (address));
    }
    function exclude(address val) public override onlyMember returns(address) {
        (bool success, bytes memory result) = address(implementation).
            delegatecall(abi.encodeWithSignature("exclude(address)", val));
        require(success);
        return abi.decode(result, (address));
    }
    function leave() public override  returns(address) {
        (bool success, bytes memory result) = address(implementation).
            delegatecall(abi.encodeWithSignature("leave()"));
        require(success, 'Operation failed');
        return abi.decode(result, (address));
    }
    
    function delegateTo(address val) public override {
        (bool success, ) = address(implementation).
            delegatecall(abi.encodeWithSignature("delegateTo(address)", val));
        require(success);
    }
    function undelegateFrom(address val) public override {
        (bool success, ) = address(implementation).
            delegatecall(abi.encodeWithSignature("undelegateFrom(address)", val));
        require(success);
    }
    
    function updateImplementation(address val) public override returns(address) {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("updateImplementation(address)", val));
        require(success);
        return abi.decode(result, (address));
    }
    
    function processVotingResult(uint256 id) public override {
        (bool success,) = address(implementation).
            delegatecall(abi.encodeWithSignature("processVotingResult(uint256)", id));
        require(success);
    }
    
    function destroy() public override {
        if(members_count == 1) {
            cancel_membership_action.destroy();
            cancel_exclusion_action.destroy();
            member_add_action.destroy();
            member_exclude_action.destroy();
            member_leave_action.destroy();
            empty_action.destroy();

            implementation.destroy();
        
            selfdestruct(msg.sender);
        }
    }
}
