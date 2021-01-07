// SPDX-License-Identifier: MIT

pragma solidity >=0.7.5;
pragma abicoder v2;

import "../interface/AllianceStorage.sol";
import "../interface/IAlliance.sol";
import "../interface/Owned.sol";
import "../interface/Election.sol";

contract DefaultAllianceImplementation is
    AllianceStorage,
    IAlliance,
    Owned
{    
    constructor() {}

    function isMember(address val) public view override returns(bool) {
        return members_info[val].is_member;
    }
    function membersCount() public view override returns(uint256) {
        return members.length;
    }

    function join(address val) public override {
        require(!isMember(val), "Already a member of the alliance.");

        Election election =  memberElection(val,
                                            "Accept the candidate",
                                            "",
                                            actions["accept_candidate"],
                                            "Reject the candidate",
                                            "",
                                            actions["reject_candidate"]);

        candidates_for_membership[val] = address(election);
    }

    function exclude(address val) public override onlyMember {
        require(isMember(val), "Not a member of the alliance.");
        require(
            msg.sender != val,
            "You can't exclude yourself, choose 'leave' option"
        );

        Election election =  memberElection(val,
                                            "Keep",
                                            "Keep candidate's membership",
                                            actions["reject_exclusion"],
                                            "Exclude",
                                            "Exclude candidate",
                                            actions["reject_exclusion"]);

        candidates_for_exclusion[val] = address(election);
    }

    function leave() public override onlyMember {
        (bool success,) = address(actions["leave_alliance"]).
            delegatecall(abi.encodeWithSignature("execute(address)", msg.sender));
        require(success, "Can't call remove action");
    }

    function delegateTo(address val) public override onlyMember {}

    function undelegateFrom(address val) public override onlyMember {}

    function updateImplementation(address val) public override onlyMember {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Update";
        proposals[0].description = "Update the implementation.";
        proposals[0].action_data = val;
        proposals[0].won_action = actions["update_impl"];

        proposals[1].name = "Not update";
        proposals[1].description = "Don't update the implementation.";
        proposals[1].won_action = actions["no_action"];

        // Election election = newElection(proposals);
    }

    function processVotingResult(address el_addr) public override {
        address el_creator = elections[el_addr];
        require(el_creator != address(0), 
            "The election of another alliance cannot be processed.");
        IElection election = IElection(el_addr);

        (address data, IAction action) = election.winner();
        (bool success,) = address(action).
            delegatecall(abi.encodeWithSignature("execute(address)", data));
        require(success);

        election.destroy();
        elections[el_addr] = address(0);
    }

    function createElection(Election.Proposal[] memory proposals) public override {
    }

    function destroy() public onlyOwner override(IAlliance, Owned) {
        Owned.destroy();
    }

    function memberElection(address candidate,
                            string memory accept_name,
                            string memory accept_desc,
                            IAction accept_action,
                            string memory reject_name,
                            string memory reject_desc,
                            IAction reject_action) internal returns(Election) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name        = accept_name;
        proposals[0].description = accept_desc;
        proposals[0].action_data = candidate; 
        proposals[0].won_action  = accept_action;

        proposals[1].name        = reject_name;
        proposals[1].description = reject_desc;
        proposals[1].action_data = candidate;
        proposals[1].won_action  = reject_action;

        Election election = new Election(proposals,
                reject_action,
                reject_action,
                reject_action,
                block.timestamp + 1000,
                5,
                5,
                1
            );

        elections[address(election)] = msg.sender;

        return election;
    }

    function newElection(Election.Proposal[] memory proposals) internal returns(Election) {
        Election election = new Election(proposals,
                actions["no_acton"],
                actions["no_acton"],
                actions["no_acton"],
                block.timestamp + 1000,
                5,
                5,
                1
            );

        elections[address(election)] = msg.sender;

        return election;
    }
}
