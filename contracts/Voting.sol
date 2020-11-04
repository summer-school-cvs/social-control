pragma solidity >=0.5.0;

contract Voting {
    address public votingCreator;

    // restrictions
    bool public Ended;
    uint256 public votingEndTime;
    bool public authByOwner;

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
        bool voted;
        uint16 votePower;
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(uint8 => Discard) public discards;
    mapping(address => Voter) public voters;

    uint8 public proposalsCount;

    constructor(uint256 _durationMinutes, bool _authByOwner) public {
        votingCreator = msg.sender;
        Ended = false;
        authByOwner = _authByOwner;
        votingEndTime = block.timestamp + (_durationMinutes * 1 minutes);
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
        voters[msg.sender].voted = false;
        // Default (not delegate)
        voters[msg.sender].votePower = 1;
    }

    function authorize(address _voterAdress) public {
        require(msg.sender == votingCreator);
        voters[_voterAdress].voted = false;
        // Default (not delegate)
        voters[_voterAdress].votePower = 1;
    }

    function vote(uint8 _proposalId) public {
        require(!Ended, "Voting was ended by creator.");
        require(block.timestamp < votingEndTime, "Voting is over.");

        // check that voter had never voted
        require(!voters[msg.sender].voted, "Voter already voted.");

        // only valid id of proposal
        require(
            _proposalId > 0 && _proposalId <= proposalsCount,
            "Incorrect ID of the proposal."
        );

        // record that address has voted
        voters[msg.sender].voted = true;

        // increase vote count for proposal
        proposals[_proposalId].voteCount += voters[msg.sender].votePower;
    }

    function discard() public {
        require(!Ended, "Voting was ended by creator.");
        require(block.timestamp < votingEndTime, "Voting is over.");
        require(!voters[msg.sender].voted, "Voter already voted.");

        voters[msg.sender].voted = true;

        discards[0].voteCount += voters[msg.sender].votePower;
    }

    function endVote() public {
        require(msg.sender == votingCreator);
        Ended = true;
    }
}
