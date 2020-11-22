pragma solidity >=0.5.0;

abstract contract IAction  {
    function execute(address) public virtual;
}
