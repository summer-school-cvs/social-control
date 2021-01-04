// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;
pragma abicoder v2;

import "./Election.sol";

abstract contract IAlliance {
    // TODO: view
    function isMember(address) public virtual returns(bool);

    function join(address val) public virtual returns(address);
    function exclude(address val) public virtual returns(address);
    function leave() public virtual returns(address);
    
    function delegateTo(address) public virtual;
    function undelegateFrom(address) public virtual;
    
    function updateImplementation(address) public virtual returns(address);
    
    function processVotingResult(uint256 id) public virtual;

    function createElection(Election.Proposal[] memory proposals) public virtual returns(address);

    function destroy() public virtual;
}
