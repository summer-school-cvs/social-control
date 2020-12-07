// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./IAlliance.sol";
import "./IAction.sol";

contract AllianceStorage {
    struct MemberInfo {
        address[] supportive;
        bool is_member;
    }

    IAlliance public implementation;

    IAction public cancel_membership_action;
    IAction public cancel_exclusion_action;
    IAction public member_add_action;
    IAction public member_exclude_action;
    IAction public member_leave_action;
    IAction public empty_action;
    IAction public update_impl_action;

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
