// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;
pragma abicoder v2;

import "./Election.sol";

abstract contract IAlliance {
    function isMember(address) public view virtual returns(bool);
    function membersCount() public view virtual returns(uint256);

    function join(address val) public virtual;
    function exclude(address val) public virtual;
    function leave() public virtual;
    
    function delegateTo(address) public virtual;
    function undelegateFrom(address) public virtual;
    
    function updateImplementation(address) public virtual;
    
    function processVotingResult(uint256 id) public virtual;

    function createElection(Election.Proposal[] memory proposals) public virtual;

    function destroy() public virtual;
}
