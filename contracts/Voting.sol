pragma solidity >=0.5.0;

contract Voting {
    string public name;
    string public description;

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

    mapping(uint8 => Proposal) public proposals;
    mapping(uint8 => Discard) public discards;
    mapping(address => bool) public voters;

    uint8 public proposalsCount;

    // TODO: automatically init constructor: factory/voting ???
    constructor() public {
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

    function vote(uint8 _proposalId, uint16 votePower) public {
        // check that never voted
        require(!voters[msg.sender]);

        // only valid id of candidate
        require(_proposalId > 0 && _proposalId <= proposalsCount);

        // record that address has voted
        voters[msg.sender] = true;

        // increase vote count for proposal
        proposals[_proposalId].voteCount += votePower;
    }

    function discard(uint16 votePower) public {
        require(!voters[msg.sender]);
        voters[msg.sender] = true;

        discards[0].voteCount += votePower;
    }
}
