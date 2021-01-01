// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma abicoder v2;

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
        
        actions["accept_candidate"] = new AddMember();
        actions["reject_candidate"] = new RemoveCandidateForMembership();
        actions["accept_exclusion"] = new RemoveMember();
        actions["reject_exclusion"] = new EmptyAction(); // TODO
        actions["update_impl"]      = new UpdateImpl();
        actions["no_acton"]         = new EmptyAction();
        actions["leave_alliance"]   = new RemoveMember();
    }

    function isMember(address val) public view override returns(bool) {
        (bool success, bytes memory result) = address(implementation).
            staticcall(abi.encodeWithSignature("isMember(address)", val));
        require(success);        
        return abi.decode(result, (bool));
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
        require(success);
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


    function createElection(Election.Proposal[] memory proposals) public override returns(address) {
        (bool success, bytes memory result) = address(implementation).delegatecall(abi.encodeWithSignature("createElection((Election.Proposal[] memory)", proposals));
        require(success);
        return abi.decode(result, (address));
    }
    
    function destroy() public override {
        if(members_count == 1) {
            actions["accept_candidate"].destroy();
            actions["reject_candidate"].destroy();
            actions["accept_exclusion"].destroy();
            actions["reject_exclusion"].destroy();
            actions["update_impl"]     .destroy();
            actions["no_acton"]        .destroy();
            actions["leave_alliance"]  .destroy(); 

            actions["accept_candidate"] = IAction(0);
            actions["reject_candidate"] = IAction(0);
            actions["accept_exclusion"] = IAction(0);
            actions["reject_exclusion"] = IAction(0);
            actions["update_impl"]      = IAction(0);
            actions["no_acton"]         = IAction(0);
            actions["leave_alliance"]   = IAction(0);

            implementation.destroy();
        
            selfdestruct(msg.sender);
        }
    }
}
