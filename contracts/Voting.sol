pragma solidity >=0.5.0;

contract Voting {
    struct Proposal {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public voters;

    uint256 public proposalsCount;

    constructor() public {
        addProposal("White");
        addProposal("Black");
    }

    function addProposal(string memory _name) private {
        proposalsCount++;
        proposals[proposalsCount] = Proposal(proposalsCount, _name, 0);
    }

    function castVote(uint8 _proposalId, uint32 votePower) public {
        // check that never voted
        require(!voters[msg.sender]);

        // only valid id of candidate
        require(_proposalId > 0 && _proposalId <= proposalsCount);

        // record that address has voted
        voters[msg.sender] = true;

        // increase vote count for proposal
        proposals[_proposalId].voteCount =
            proposals[_proposalId].voteCount +
            votePower;
    }
}
