// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./IAlliance.sol";
import "./IAction.sol";

contract AllianceStorage {
    struct MemberInfo {
        address[] supportive;
        bool is_member;
        uint256 index;
    }

    IAlliance public implementation;

    mapping(string => IAction) actions;

    mapping(address => MemberInfo) public members_info;
    address[] members;

    // mapping(candidate, add action(votings))
    mapping(address => address) public candidates_for_membership;
    mapping(address => address) public candidates_for_exclusion;

    // mapping(voting, creator)
    mapping(address => address) public elections;

    modifier onlyMember() {
        require(members_info[msg.sender].is_member);
        _;
    }
}
