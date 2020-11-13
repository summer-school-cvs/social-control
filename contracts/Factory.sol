pragma solidity >=0.6.0;

import "./Voting.sol";

contract Factory {
    struct MemberInfo {
        address[] supportive;
        bool isMember;
    }
    
    modifier onlyMember() {
        require(members[msg.sender].isMember, "");
        _;
    }
    
    constructor() public {
        members[msg.sender].isMember = true;
    }
    
    function addMember(address val) public returns(address) {
        // TODO: val is contract ???? 
        require(!members[val].isMember, "Already added.");
        require(add_member_candidates[val] != address(0), "Already on the list of candidates.");
        
        address add_interaction = address(0); // TODO
        add_member_candidates[val] = add_interaction;
        
        return add_interaction;
    }
    
    function  exclude(address val) public onlyMember returns(address) {
        require(delete_member_candidates[val] != address(0), "Already on the list of candidates for exclusion.");
        
        address delete_interaction = address(0); // TODO
        delete_member_candidates[val] = delete_interaction;
        
        return delete_interaction;
    }
    
    function  leave() public onlyMember returns(address) {
        require(delete_member_candidates[msg.sender] != address(0), "Already on the list of candidates for exclusion.");
        
        address delete_interaction = address(0); // TODO
        delete_member_candidates[msg.sender] = delete_interaction;
        
        return delete_interaction;
    }


    function  isMember(address val) view public returns(bool) {
        return members[val].isMember;
    }
    

    function delegateTo(address) public onlyMember returns(bool) {
        return false; // TODO: delegates
    }
    
    function votePower(address) public onlyMember returns(uint) {
        return 1;
    }
    

    function createVoting() public {
        Voting voting = new Voting(100, false);
        votings[address(voting)] = msg.sender;
    }
    
    function execute(address vote) public {
        require(votings[vote] != address(0));
        // val.delegatecall(); // TODO: delegatecall proposal action
    }
    
    
    // TODO
    address private member_add_action;
    address private member_delete_action;
    address private member_own_delete_action;
    
    mapping(address=>MemberInfo) members;
    
    // mapping(candidate, add action)
    mapping(address => address) public add_member_candidates;
    mapping(address => address) public delete_member_candidates;
    
    // mapping(voting, creator)
    mapping(address => address) votings;
}
