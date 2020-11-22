pragma solidity >=0.5.0;

import "./IAction.sol";

contract Election  {
    
    struct Voter {
        int8 vote;
        bool discard;
    }
    
    struct Proposal {
        string name;
        string description;
        IAction won_action;
        uint256 vote_count;
    }
    
    address owner;
    Proposal[] public proposals;
    mapping(address => Voter) public authorized_votes;
    mapping(address => Voter) public not_authorized_votes;
    
    uint256 public discards;
    
    uint256 public immutable failed_threshold;
    uint256 public immutable win_ratio;
    uint256 public immutable discard_threshold;
    
    constructor(uint256 f_th, uint256 wr, uint256 desc_th) public {
        owner = msg.sender;
        
        failed_threshold = f_th;
        win_ratio = wr;
        discard_threshold = desc_th;
    }

    function vote(uint8 id, uint256 power) public returns(uint256) {
        return 0;
    }
    
    function discard() public {    
    }
}
