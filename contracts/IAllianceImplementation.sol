// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

abstract contract IAllianceImplementation {
    function join(address val) public virtual returns(address);
    function exclude(address val) public virtual returns(address);
    function leave() public virtual returns(address);
    
    function delegateTo(address) public virtual;
    function undelegateFrom(address) public virtual;
    
    function updateImplementation(address) public virtual returns(address);
    
    function processVotingResult(uint256 id) public virtual;

    function destroy() public virtual;
}
