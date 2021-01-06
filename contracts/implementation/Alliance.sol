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
        members_info[msg.sender].is_member = true;
        members_info[msg.sender].index = members.length;
        members.push(msg.sender);
        
        actions["accept_candidate"] = new AddMember();
        actions["reject_candidate"] = new RemoveCandidateForMembership();
        actions["accept_exclusion"] = new RemoveMember();
        actions["reject_exclusion"] = new EmptyAction(); // TODO
        actions["update_impl"]      = new UpdateImpl();
        actions["no_acton"]         = new EmptyAction();
        actions["leave_alliance"]   = new RemoveMember();
    }

    function isMember(address val) public view override returns(bool) {
        // TODO: delegatecall. But it's view...
        return members_info[val].is_member;
    }
    function membersCount() public view override returns(uint256) {
        return members.length;
    }
    
    function join(address val) public override {
        (bool success, ) = address(implementation).
            delegatecall(abi.encodeWithSignature("join(address)", val));
        require(success);        
    }
    function exclude(address val) public override onlyMember {
        (bool success, ) = address(implementation).
            delegatecall(abi.encodeWithSignature("exclude(address)", val));
        require(success);
    }
    function leave() public override  {
        (bool success, ) = address(implementation).
            delegatecall(abi.encodeWithSignature("leave()"));
        require(success);
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
    
    function updateImplementation(address val) public override {
        (bool success, ) = address(implementation).delegatecall(abi.encodeWithSignature("updateImplementation(address)", val));
        require(success);
    }
    
    function processVotingResult(uint256 id) public override {
        (bool success,) = address(implementation).
            delegatecall(abi.encodeWithSignature("processVotingResult(uint256)", id));
        require(success);
    }


    function createElection(Election.Proposal[] memory proposals) public override {
        (bool success, ) = address(implementation).delegatecall(abi.encodeWithSignature("createElection((Election.Proposal[] memory)", proposals));
        require(success);
    }
    
    function destroy() public override onlyMember {
        if(members.length == 1) {
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
        
            selfdestruct(payable(members[0]));
        }
    }
}
