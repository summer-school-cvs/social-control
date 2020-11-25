pragma solidity >=0.5.0;

import "./IAction.sol";
import "./Alliance.sol";

contract Election {
    struct Voter {
        uint256 vote;
        bool discard;
        bool voted;
        uint256 prevVotePower;
    }

    struct Proposal {
        string name;
        string description;
        IAction won_action;
        uint256 vote_count;
    }

    address owner;
    Alliance impl = Alliance(owner);

    uint256 end_time;

    Proposal[] public proposals;
    mapping(address => Voter) public authorized_votes;
    mapping(address => Voter) public not_authorized_votes;

    uint256 public discards;

    uint256 public immutable failed_threshold;
    uint256 public immutable win_ratio;
    uint256 public immutable discard_threshold;

    constructor(
        uint256 f_th,
        uint256 wr,
        uint256 desc_th
    ) public {
        owner = msg.sender;
        end_time = block.timestamp + (1440 * 1 minutes);
        failed_threshold = f_th;
        win_ratio = wr;
        discard_threshold = desc_th;
    }

    // power ??
    function vote(uint256 id, uint256 power) public returns (uint256) {
        require(block.timestamp < end_time, "Election is over.");
        require(
            id >= 0 && id <= proposals.length,
            "Incorrect ID of the proposal."
        );

        if (checkVoterAuthorization()) {
            if (authorized_votes[msg.sender].voted) {
                proposals[authorized_votes[msg.sender].vote]
                    .vote_count -= authorized_votes[msg.sender].prevVotePower;

                // change to new id
                authorized_votes[msg.sender].vote = id;

                proposals[authorized_votes[msg.sender].vote]
                    .vote_count += power;

                authorized_votes[msg.sender].prevVotePower = power;
            }
            if (authorized_votes[msg.sender].discard) {
                authorized_votes[msg.sender].discard = false;
                authorized_votes[msg.sender].voted = true;
                discards -= authorized_votes[msg.sender].prevVotePower;
                authorized_votes[msg.sender].vote = id;

                proposals[authorized_votes[msg.sender].vote]
                    .vote_count += power;
                authorized_votes[msg.sender].prevVotePower = power;
            }
            if (
                !authorized_votes[msg.sender].discard &&
                !authorized_votes[msg.sender].voted
            ) {
                authorized_votes[msg.sender].voted = true;
                authorized_votes[msg.sender].vote = id;
                proposals[authorized_votes[msg.sender].vote]
                    .vote_count += power;
                authorized_votes[msg.sender].prevVotePower = power;
            }
        } else {
            if (not_authorized_votes[msg.sender].voted) {
                proposals[not_authorized_votes[msg.sender].vote]
                    .vote_count -= 1;

                // change to new id
                not_authorized_votes[msg.sender].vote = id;

                proposals[not_authorized_votes[msg.sender].vote]
                    .vote_count += 1;
            }
            if (not_authorized_votes[msg.sender].discard) {
                not_authorized_votes[msg.sender].discard = false;
                not_authorized_votes[msg.sender].voted = true;
                discards -= 1;
                not_authorized_votes[msg.sender].vote = id;

                proposals[not_authorized_votes[msg.sender].vote]
                    .vote_count += 1;
            }
            if (
                !not_authorized_votes[msg.sender].discard &&
                !not_authorized_votes[msg.sender].voted
            ) {
                not_authorized_votes[msg.sender].voted = true;
                not_authorized_votes[msg.sender].vote = id;
                proposals[authorized_votes[msg.sender].vote].vote_count += 1;
            }
        }
        return id;
    }

    function discard(uint256 power) public {
        require(block.timestamp < end_time, "Election is over.");
        require(!authorized_votes[msg.sender].discard, "Already discarded");
        require(!not_authorized_votes[msg.sender].discard, "Already discarded");

        if (checkVoterAuthorization()) {
            authorized_votes[msg.sender].discard = true;
            if (authorized_votes[msg.sender].voted) {
                proposals[authorized_votes[msg.sender].vote]
                    .vote_count -= authorized_votes[msg.sender].prevVotePower;

                // change to invalid proposal id
                authorized_votes[msg.sender].vote = 0;
                authorized_votes[msg.sender].voted = false;
                authorized_votes[msg.sender].prevVotePower = power;
            }
            discards += power;
        } else {
            not_authorized_votes[msg.sender].discard = true;

            // not_auth can't have delegates -> no previous power

            if (not_authorized_votes[msg.sender].voted) {
                proposals[not_authorized_votes[msg.sender].vote]
                    .vote_count -= 1;

                not_authorized_votes[msg.sender].vote = 0;
                not_authorized_votes[msg.sender].voted = false;
            }
            discards += 1;
        }
    }

    function checkVoterAuthorization() public returns (bool) {
        bool member_status = impl.members(msg.sender);
        if (member_status) {
            return true;
        } else {
            return false;
        }
    }
}
