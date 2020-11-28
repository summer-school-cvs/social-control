// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./IAllianceImplementation.sol";
import "./IAction.sol";

contract AllianceStorage {
    struct MemberInfo {
        address[] supportive;
        bool is_member;
    }

    IAllianceImplementation public implementation;

    IAction public remove_membership_candidate_action;
    IAction public remove_exclusion_candidate_action;
    IAction public member_add_action;
    IAction public member_delete_action;
    IAction public member_own_delete_action;
    IAction public empty_action;

    mapping(address => MemberInfo) public members;

    // mapping(candidate, add action(votings))
    mapping(address => address) public candidates_for_membership;
    mapping(address => address) public candidates_for_exclusion;
    uint256 public members_count;

    // mapping(voting, creator)
    mapping(address => address) public elections;

    modifier onlyMember() {
        require(members[msg.sender].is_member);
        _;
    }
}
