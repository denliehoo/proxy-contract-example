// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
import "./Storage.sol";

// no state variables here; all should be in Storage.sol!
contract FunctionalDogs is Storage {
    constructor() {
        owner = msg.sender;
    }

    function getNumberOfDogs() public view returns (uint256) {
        return _uintStorage["Dogs"];
    }

    function setNumberOfDogs(uint256 _toSet) public {
        _uintStorage["Dogs"] = _toSet;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }
}

// lets say we deployed this and we forgot to put the onlyOwner modifier
// in the setter functions. Now, we want to fix this problem in the V2 contract.
