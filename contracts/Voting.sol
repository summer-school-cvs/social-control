pragma solidity >=0.5.0;

contract Voting {
    address public votingCreator;

    // restrictions
    bool public Ended;
    uint256 private votingEndTime;
    bool public authByOwner;
    // defines a percent of votes to win
    uint16 private validPercent;

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
    }
    
    struct Decision {
        uint16 prevVotePower;
        uint8 proposalId;
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(uint8 => Discard) public discards;
    mapping(address => Voter) public voters;
    mapping(address => Decision) public decisions;

    uint8 public proposalsCount;

    constructor(uint16 _validPercent, uint256 _durationMinutes, bool _authByOwner) public {
        votingCreator = msg.sender;
        Ended = false;
        authByOwner = _authByOwner;
        votingEndTime = block.timestamp + (_durationMinutes * 1 minutes);
        validPercent = _validPercent;
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
        voters[msg.sender].votePower = 1;
    }

    function authorize(address _voterAdress) public {
        require(msg.sender == votingCreator);
        // Default (not delegate)
        voters[_voterAdress].votePower = 1;
    }

    function vote(uint8 _proposalId) public {
        require(!Ended, "Voting was ended by creator.");
        require(block.timestamp < votingEndTime, "Voting is over.");

        // only valid id of proposal
        require(
            _proposalId > 0 && _proposalId <= proposalsCount,
            "Incorrect ID of the proposal."
        );

        // check if user has a previous decision
        if (decisions[msg.sender]) {
            // change proposal count with previous decision (return to state without sender adress vote)
            proposals[decisions[msg.sender].proposalId].voteCount -= decisions[msg.sender].prevVotePower;

            // write new decision
            decisions[msg.sender].proposalId = _proposalId

            // vote power in decision becomes a previous for next vote by adress
            // current vote power may be different
            decisions[msg.sender].prevVotePower = voters[msg.sender].votePower
            
            // now, when we wrote current vote power -> add it to proposal count
            proposals[_proposalId].voteCount += voters[msg.sender].votePower;
        } else {
            // voting first time
            decisions[msg.sender].prevVotePower = voters[msg.sender].votePower
            decisions[msg.sender].proposalId = _proposalId
            proposals[_proposalId].voteCount += voters[msg.sender].votePower;
        }
    }

    function discard() public {
        require(!Ended, "Voting was ended by creator.");
        require(block.timestamp < votingEndTime, "Voting is over.");

        discards[0].voteCount += voters[msg.sender].votePower;
    }

    function endVote() public {
        require(msg.sender == votingCreator);
        Ended = true;
    }
}
