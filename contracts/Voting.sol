pragma solidity >=0.5.0;

contract Voting {
    struct Proposal {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    mapping(uint256 => Proposal) public proposals;

    uint256 public proposalsCount;

    constructor() public {
        addProposal("White");
        addProposal("Black");
    }

    function addProposal(string memory _name) private {
        proposalsCount++;
        proposals[proposalsCount] = Proposal(proposalsCount, _name, 0);
    }
}
