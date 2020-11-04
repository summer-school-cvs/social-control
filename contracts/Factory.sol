pragma solidity >=0.5.0;

import "./Voting.sol";

contract Factory {
    mapping(address => bool) votingAddresses;

    function createVoting() public {
        Voting voting = new Voting(100, false);
        votingAddresses[address(voting)] = true;
    }
}
