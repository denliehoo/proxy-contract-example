// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
import "./Storage.sol";

// no state variables here; all should be in Storage.sol!
contract FunctionalDogsV2 is Storage {
    constructor() {
        // owner = msg.sender;
        initialize(msg.sender);
    }

    /*    initialize takes the arguments that are in the constructor (Hence, if we
    have more arguements than owner, we should put it there too)
    This solves the issue in the constructor function whereby it only exists
    in the functional contract but not the proxy
    initialize should also only be able to be called once
    =================================================================
    hence; initialize is called once when deploying function contract
    and then, later, once deployed, we would have to call initialize again from
    our proxy contract. So the reason why we have to call initialize again is that
    when deploying this functional contract, the owner = msg.sender only in 
    this functional contract; but not in the proxy contract since it did not do a delegatecall.
    Hence, we have to delegatecall initialize in the proxy contract
    (after deploying in the migrations file) so that owner is also = msg.sender in
    the proxy contract too; hence making both contract have the same state again */
    function initialize(address _owner) public {
        // remember: there is a variable called _initialized defiend in Storage
        // which defaults to false; hence, we can only use the function if _initalized is false
        require(
            !_initialized,
            "Contract has already been initialized, unable to call again"
        );
        owner = _owner;
        _initialized = true;
    }

    function getNumberOfDogs() public view returns (uint256) {
        return _uintStorage["Dogs"];
    }

    function setNumberOfDogs(uint256 _toSet) public onlyOwner {
        _uintStorage["Dogs"] = _toSet;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }
}
