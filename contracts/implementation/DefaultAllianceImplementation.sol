// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma abicoder v2;

import "../interface/AllianceStorage.sol";
import "../interface/IAlliance.sol";
import "../interface/Owned.sol";
import "./Election.sol";

contract DefaultAllianceImplementation is
    AllianceStorage,
    IAlliance,
    Owned
{    
    constructor() {
        members[msg.sender].is_member = true;
    }

    function join(address val) public override returns (address) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Accept";
        proposals[0].description = "blablabla";
        proposals[0].action_data = val;
        proposals[0].won_action = member_add_action;

        proposals[1].name = "Not accept";
        proposals[1].description = "blablabla";
        proposals[1].won_action = cancel_membership_action;

        Election election = new Election(proposals);

        candidates_for_membership[val] = address(election);
        elections[address(election)] = msg.sender;

        return address(election);
    }

    function exclude(address val) public override onlyMember returns (address) {
        require(
            msg.sender != val,
            "You can't exclude yourself, choose 'leave' option"
        );
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Keep";
        proposals[0].description = "Keep candidate's membership";
        proposals[0].action_data = val;
        proposals[0].won_action = cancel_exclusion_action;

        proposals[1].name = "Exclude";
        proposals[1].description = "Exclude candidate";
        proposals[1].won_action = member_exclude_action;

        Election election = new Election(proposals);

        candidates_for_exclusion[val] = address(election);
        elections[address(election)] = msg.sender;

        return address(election);
    }

    function leave() public override onlyMember returns (address) {
        (bool success,) = address(member_leave_action).
            delegatecall(abi.encodeWithSignature("execute(address payable)", msg.sender));
        // require(success, 'Operation failed');

        return address(0);
    }

    function delegateTo(address val) public override onlyMember {}

    function undelegateFrom(address val) public override onlyMember {}

    function updateImplementation(address val) public override onlyMember returns (address) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Update";
        proposals[0].description = "Update the implementation.";
        proposals[0].action_data = val;
        proposals[0].won_action = update_impl_action;

        proposals[1].name = "Not update";
        proposals[1].description = "Don't update the implementation.";
        proposals[1].won_action = empty_action;

        Election election = new Election(proposals);

        elections[address(election)] = msg.sender;

        return address(election);
    }

    function processVotingResult(uint256) public override {
        Election election = Election(msg.sender);

        // candidate address, action for candidate
        (address data, IAction action) = election.winner();
        (bool success,) = address(action).
            delegatecall(abi.encodeWithSignature("execute(address payable)", data));
        require(success);
    }

    function destroy() public onlyOwner override(IAlliance, Owned) {
        Owned.destroy();
    }
}
