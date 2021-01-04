// SPDX-License-Identifier: MIT

pragma solidity >=0.7.5;
pragma abicoder v2;

import "./IAction.sol";
import "./IAlliance.sol";
import "./Owned.sol";

abstract contract IElection is Owned {
    struct Voter {
        uint256 vote;
        bool voted;
    }

    struct Proposal {
        string  name;
        string  description;
        address action_data;
        IAction won_action;
    }

    uint256 public immutable end_time;

    IAction public immutable no_quorum_action;
    IAction public immutable discard_action;
    IAction public immutable no_winner_action;

    IAlliance public immutable alliance;

    // TODO: mast be constant
    Proposal[] public proposals;

    address[] public                 voters;
    mapping(address => Voter) public votes;

    constructor(Proposal[] memory _proposals,
                uint256 _end_time,
                IAction _no_quorum_action,
                IAction _discard_action  ,
                IAction _no_winner_action) {
            require(IAlliance(owner()) != IAlliance(address(0)),
                "The elections must be created by the alliance.");
            require(block.timestamp < _end_time,
                "The end of the elections should be in the future.");
            require(_proposals.length > 1,
                "The number of proposals must be greater than 1.");

            alliance = IAlliance(owner());

            for(uint i = 0; i < _proposals.length; ++i)
                proposals.push(_proposals[i]);

            end_time = _end_time;

            no_quorum_action = _no_quorum_action;
            discard_action   = _discard_action  ;
            no_winner_action = _no_winner_action;
    }

    function vote(uint256 id) public {
        require(id >= 0 && id < proposals.length,
            "Incorrect ID of the proposal.");

        addVote(msg.sender, id);
    }

    function discard() public {
        addVote(msg.sender, proposals.length);
    }

    function winner() view public virtual returns(address data, IAction);

    function addVote(address voter, uint256 id) internal {
        require(block.timestamp < end_time, "Election is over.");
        if(!votes[voter].voted) {
            voters.push(voter);
            votes[voter].voted = true;
        }
        votes[voter].vote = id;
    }
}