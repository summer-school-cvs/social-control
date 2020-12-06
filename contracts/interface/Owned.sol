// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

contract Owned  {
    address private _owner;
    address private _new_owner;
    
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    
    constructor() {
        _owner = msg.sender;
    }
    
    function owner() public view returns(address) {
        return _owner;
    }
    
    function changeOwner(address val) public onlyOwner {
        _new_owner = val;
    }
    
    function confirmOwnership() public {
        require(msg.sender == _new_owner);
        _owner = _new_owner;
        _new_owner = address(0);
    }
    
    function destroy() public onlyOwner virtual {
        selfdestruct(msg.sender);
    }
}
