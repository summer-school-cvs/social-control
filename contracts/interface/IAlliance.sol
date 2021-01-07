// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;
pragma abicoder v2;

import "./IElection.sol";

abstract contract IAlliance {
    function isMember(address) public view virtual returns(bool);
    function membersCount() public view virtual returns(uint256);

    function join(address val) public virtual;
    function exclude(address val) public virtual;
    function leave() public virtual;
    
    function delegateTo(address) public virtual;
    function undelegateFrom(address) public virtual;
    
    function updateImplementation(address) public virtual;
    
    function processVotingResult(address) public virtual;

    function createElection(IElection.Proposal[] memory proposals) public virtual;

    function destroy() public virtual;
}
