pragma solidity >=0.5.0;

import "./IAllianceImplementation.sol";
import "./IAction.sol";

contract AllianceStorage {
    struct MemberInfo {
        address[] supportive;
        bool is_member;
    }
    
    IAllianceImplementation public implementation;
    
    IAction public member_add_action;
    IAction public member_delete_action;
    IAction public member_own_delete_action;
    IAction public empty_action;

    mapping(address => MemberInfo) public members;

    // mapping(candidate, add action(votings))
    mapping(address => address) public candidates_for_membership;
    mapping(address => address) public candidates_for_exclusion;

    // mapping(voting, creator)
    mapping(address => address) public elections;
}
