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

    function join(address val) public override returns (address) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Accept";
        proposals[0].description = "blablabla";
        proposals[0].action_data = val;
        proposals[0].won_action = actions["accept_candidate"];

        proposals[1].name = "Not accept";
        proposals[1].description = "blablabla";
        proposals[1].won_action = actions["reject_candidate"];

        Election election = newElection(proposals);
        candidates_for_membership[val] = address(election);

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
        proposals[0].won_action = actions["accept_exclusion"];

        proposals[1].name = "Exclude";
        proposals[1].description = "Exclude candidate";
        proposals[1].won_action = actions["reject_exclusion"];

        Election election = newElection(proposals);
        candidates_for_exclusion[val] = address(election);

        return address(election);
    }

    function leave() public override onlyMember returns (address) {
        (bool success,) = address(actions["leave_alliace"]).
            delegatecall(abi.encodeWithSignature("execute(address payable)", msg.sender));
        require(success);

        return address(0);
    }

    function delegateTo(address val) public override onlyMember {}

    function undelegateFrom(address val) public override onlyMember {}

    function updateImplementation(address val) public override onlyMember returns (address) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Update";
        proposals[0].description = "Update the implementation.";
        proposals[0].action_data = val;
        proposals[0].won_action = actions["update_impl"];

        proposals[1].name = "Not update";
        proposals[1].description = "Don't update the implementation.";
        proposals[1].won_action = actions["no_action"];

        Election election = newElection(proposals);

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

    function createElection(Election.Proposal[] memory proposals) public override returns(address) {
        return address(newElection(proposals));
    }

    function destroy() public onlyOwner override(IAlliance, Owned) {
        Owned.destroy();
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
