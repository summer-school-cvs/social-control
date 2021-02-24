// SPDX-License-Identifier: MIT

pragma solidity >=0.7.5;
pragma abicoder v2;

import "../../interface/IElection.sol";

contract AbsoluteElection is IElection {
    uint256 public immutable discard_threshold;
    uint256 public immutable quorum_threshold;
    uint256 public immutable win_threshold;

    constructor(string memory _name,
                string memory _description,
                Proposal[] memory _proposals,
                IAction _no_quorum_action,
                IAction _discard_action,
                IAction _no_winner_action,
                uint256 _end_time,
                uint256 _discard_threshold,
                uint256 _quorum_threshold,
                uint256 _win_threshold
    ) IElection(_name, _description, _proposals, _end_time, _no_quorum_action, _discard_action, _no_winner_action) {
        for(uint i = 0; i < _proposals.length; ++i) {
            proposals.push(_proposals[i]);
        }

        discard_threshold = _discard_threshold;
        quorum_threshold  = _quorum_threshold;
        win_threshold     = _win_threshold;
    }

    function winner() view public override returns(address data, IAction action) {
        uint discard_index = proposals.length;
        (uint256[] memory distribution, uint256 quorum) = distributionOfVotes();

        uint256 members_cnt = alliance.membersCount();
        if(members_cnt > 1)
            members_cnt -= 1;

        uint256 d_th = discard_threshold < members_cnt ? discard_threshold: members_cnt;
        uint256 q_th = quorum_threshold  < members_cnt ? quorum_threshold : members_cnt;
        uint256 w_th = win_threshold     < members_cnt ? win_threshold    : members_cnt;

        if(d_th <= distribution[discard_index])
            return (address(this), discard_action);
        
        if(quorum < q_th)
            return (address(this), no_quorum_action);

        bool no_winner = true;
        uint id = 0;
        uint256 votes_count = 0;
        for(uint i = 0; i < proposals.length; ++i) {
            if(votes_count < distribution[i]) {
                id = i;
                votes_count = distribution[i];
                no_winner = false;
            }
            else if( votes_count == distribution[i])
                no_winner = true;
        }
        if(no_winner
           || votes_count < w_th
           || votes_count <= distribution[discard_index])
            return (address(this), no_winner_action);

        return (proposals[id].action_data, proposals[id].won_action);
    }

    function distributionOfVotes() view internal returns(uint256[] memory, uint256) {
        uint discard_index = proposals.length;

        uint256 quorum = 0;
        uint256[] memory distribution = new uint256[](discard_index + 1);

        for(uint i = 0; i < voters.length; ++i) {
                
            address cur_voter = voters[i];
            if(!alliance.isMember(cur_voter))
                continue;

            if(votes[cur_voter].voted) {
                quorum += 1;
                distribution[votes[cur_voter].vote] += 1;
            }
        }

        return (distribution, quorum);
    }
}
