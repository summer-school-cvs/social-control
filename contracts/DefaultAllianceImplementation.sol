// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./AllianceStorage.sol";
import "./IAllianceImplementation.sol";
import "./Election.sol";

contract DefaultAllianceImplementation is
    AllianceStorage,
    IAllianceImplementation
{
    modifier onlyMember() {
        require(members[msg.sender].is_member, "");
        _;
    }

    modifier onlyOwnElection() {
        require(elections[msg.sender] == address(0), "");
        _;
    }

    function join(address val) public override returns (address) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Accept";
        proposals[0].description = "blablabla";
        proposals[0].action_data = val;
        proposals[0].won_action = member_add_action;

        proposals[1].name = "Not accept";
        proposals[1].description = "blablabla";
        proposals[1].won_action = remove_membership_candidate_action;

        Election election = new Election(); //30, 70, 30);

        candidates_for_membership[val] = address(election);
        elections[address(election)] = msg.sender;

        return address(election);
    }

    function exclude(address val) public override onlyMember returns (address) {
        Election.Proposal[] memory proposals = new Election.Proposal[](2);

        proposals[0].name = "Keep";
        proposals[0].description = "Keep candidate's membership";
        proposals[0].action_data = val;
        proposals[0].won_action = member_delete_action;

        proposals[1].name = "Exclude";
        proposals[1].description = "Exclude candidate";
        proposals[1].won_action = remove_exclusion_candidate_action;

        Election election = new Election(); //30, 70, 30);

        candidates_for_exclusion[val] = address(election);
        elections[address(election)] = msg.sender;

        return address(election);
    }

    function leave() public override onlyMember returns (address) {
        return address(0);
    }

    function delegateTo(address val) public override onlyMember {}

    function undelegateFrom(address val) public override onlyMember {}

    function updateImplementation(address)
        public
        override
        onlyMember
        returns (address)
    {
        return address(0);
    }

    function processVotingResult(uint256) public override onlyOwnElection {
        Election election = Election(msg.sender);

        (address data, IAction action) = election.winner();
        (bool success, bytes memory result) = address(action).delegatecall(
            abi.encodeWithSignature("execute(address)", data)
        );
        require(success, "");
    }
}
