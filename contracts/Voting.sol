pragma solidity >=0.5.0;

// TODO :
// ? authorization by owner with array parameter
// create separate functions for same parts

contract Voting {
    address public votingCreator;

    // restrictions
    bool public Ended;
    uint256 private votingEndTime;
    bool public authByOwner;
    // defines a percent of votes to win
    uint16 private winPercent;
    uint16 private discardPercent;

    struct Proposal {
        uint8 id;
        string name;
        string description;
        uint256 voteCount;
    }

    struct Discard {
        uint8 id;
        string name;
        uint256 voteCount;
    }

    struct Voter {
        uint16 votePower;
        bool authorized;
        bool isDelegate;
        bool delegated;
        address delegatedTo;
        uint16 delegatedVotePower;
    }

    struct Decision {
        uint16 prevVotePower;
        uint8 proposalId;
        bool discard;
        bool exists;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => Discard) public discards;
    mapping(address => Voter) public voters;
    mapping(address => Decision) public decisions;

    uint8 public proposalsCount;

    constructor(
        uint16 _winPercent,
        uint16 _discardPercent,
        uint256 _durationMinutes,
        bool _authByOwner
    ) public {
        votingCreator = msg.sender;
        Ended = false;
        authByOwner = _authByOwner;
        votingEndTime = block.timestamp + (_durationMinutes * 1 minutes);
        winPercent = _winPercent;
        discardPercent = _discardPercent;
        addProposal("White", "wall color");
        addProposal("Black", "wall color");
        addDiscard("Discard");
    }

    function addProposal(string memory _name, string memory _description)
        private
    {
        proposalsCount++;
        proposals[proposalsCount] = Proposal(
            proposalsCount,
            _name,
            _description,
            0
        );
    }

    function addDiscard(string memory _name) private {
        discards[0] = Discard(0, _name, 0);
    }

    function autoAuthorize() public {
        require(!authByOwner, "Auto-auth is prohibited by creator.");
        // Default (not delegate)
        if (!voters[msg.sender].authorized) {
            voters[msg.sender].votePower = 1;
            voters[msg.sender].authorized = true;
        }
    }

    function authorize(address _voterAdress) public {
        require(msg.sender == votingCreator);
        // need this, because otherwise creator can decrease the power
        require(!voters[_voterAdress].authorized, "Already authorized");
        voters[_voterAdress].votePower = 1;
        voters[msg.sender].authorized = true;
    }

    function vote(uint8 _proposalId) public {
        require(!Ended, "Voting was ended by creator.");
        require(block.timestamp < votingEndTime, "Voting is over.");
        if (!authByOwner) {
            autoAuthorize();
        }
        require(voters[msg.sender].authorized);
        // only valid id of proposal
        require(
            _proposalId > 0 && _proposalId <= proposalsCount,
            "Incorrect ID of the proposal."
        );

        // check if user has a previous decision
        if (decisions[msg.sender].exists) {
            if (decisions[msg.sender].discard) {
                decisions[msg.sender].discard = false;
                discards[0].voteCount -= decisions[msg.sender].prevVotePower;
            } else {
                // change proposal count with previous decision (return to state without sender adress vote)
                proposals[decisions[msg.sender].proposalId]
                    .voteCount -= decisions[msg.sender].prevVotePower;
            }
        } else {
            // if person delegated or delegated after decision
            // he has no decision
            if (voters[msg.sender].delegated) {
                // return votepower to voter
                returnVotePower();
            }
            // voting first time
            decisions[msg.sender].exists = true;
        }
        // write new decision
        decisions[msg.sender].proposalId = _proposalId;

        // vote power in decision becomes a previous for next vote by adress
        // current vote power may be different because of delegation
        decisions[msg.sender].prevVotePower = voters[msg.sender].votePower;

        // now, when we wrote current vote power -> add it to proposal count
        proposals[_proposalId].voteCount += voters[msg.sender].votePower;
    }

    function discard() public {
        require(!Ended, "Voting was ended by creator.");
        require(block.timestamp < votingEndTime, "Voting is over.");
        require(!decisions[msg.sender].discard, "Already discarded");
        if (!authByOwner) {
            autoAuthorize();
        }
        require(voters[msg.sender].authorized);

        if (decisions[msg.sender].exists) {
            proposals[decisions[msg.sender].proposalId]
                .voteCount -= decisions[msg.sender].prevVotePower;

            // change to invalid proposal id
            decisions[msg.sender].proposalId = 0;
        } else {
            decisions[msg.sender].exists = true;
        }
        discards[0].voteCount += voters[msg.sender].votePower;
        decisions[msg.sender].discard = true;
        decisions[msg.sender].prevVotePower = voters[msg.sender].votePower;
    }

    function getWinner() private {
        uint256 totalVotes = 0;
        for (uint8 i = 1; i <= proposalsCount; i++) {
            totalVotes += proposals[i].voteCount;
        }

        if (discards[0].voteCount / totalVotes > discardPercent) {
            // do something
        }

        for (uint8 i = 1; i <= proposalsCount; i++) {
            if (proposals[i].voteCount / totalVotes > winPercent) {
                // do something
            }
        }
    }

    function endVote() public {
        require(msg.sender == votingCreator);
        Ended = true;
    }

    function delegate(address _delegateAddr) public {
        if (!authByOwner) {
            autoAuthorize();
        }
        require(voters[msg.sender].authorized);
        require(
            voters[_delegateAddr].authorized,
            "Your delegate is not authorized"
        );
        require(!voters[msg.sender].delegated, "You have already delegated");
        require(
            !voters[_delegateAddr].delegated,
            "This adress already delegated"
        );

        // if voter has decision -> delete it
        // voter will be directed in "never voted" branch,
        // if votes after delegation
        if (decisions[msg.sender].exists) {
            if (decisions[msg.sender].discard = true) {
                decisions[msg.sender].discard = false;
                discards[0].voteCount -= decisions[msg.sender].prevVotePower;
            } else {
                proposals[decisions[msg.sender].proposalId]
                    .voteCount -= decisions[msg.sender].prevVotePower;
                decisions[msg.sender].proposalId = 0;
            }
            decisions[msg.sender].prevVotePower = 0;
            decisions[msg.sender].exists = false;

            voters[msg.sender].delegated = true;
            voters[msg.sender].delegatedTo = _delegateAddr;

            voters[_delegateAddr].isDelegate = true;

            voters[msg.sender].delegatedVotePower = voters[msg.sender]
                .votePower;
            voters[msg.sender].votePower = 0;
        }

        // increase delegate powers
        addDelegatePowers(voters[msg.sender].votePower, _delegateAddr);
    }

    // returns votepower to voter and takes away from delegate
    function returnVotePower() private {
        // if voter delegated he can't have votepower, because of delegate()
        voters[msg.sender].votePower += voters[msg.sender].delegatedVotePower;
        subtractDelegatePowers(
            voters[msg.sender].delegatedVotePower,
            voters[msg.sender].delegatedTo
        );
    }

    function subtractDelegatePowers(uint16 _power, address _addr) private {
        // running on chain of delegates

        // take away power from delegate
        voters[_addr].votePower -= _power;

        // we don't need to check if decision exists,
        // because delegate can't have decision
        // check if delegate delegated
        if (voters[_addr].delegated) {
            subtractDelegatePowers(_power, voters[_addr].delegatedTo);
        }
    }

    // call it in delegate()
    function addDelegatePowers(uint16 _power, address _addr) private {
        // add power to delegate
        voters[_addr].votePower += _power;

        // check if delegate delegated
        // if so, he has no decision
        if (voters[_addr].delegated) {
            addDelegatePowers(_power, voters[_addr].delegatedTo);
        }

        // if not delegated, may be not have a decision yet
        if (decisions[_addr].exists) {
            proposals[decisions[_addr].proposalId].voteCount += _power;
        }
    }
}
