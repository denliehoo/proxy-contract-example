// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
import "./Storage.sol";

contract Proxy is Storage {
    // we can add more variables to Proxy (if necessary), but not to Functional.sol
    address functionalAddress;

    constructor(address _functionalAddress) {
        functionalAddress = _functionalAddress;
    }

    function upgrade(address _newAddress) public {
        functionalAddress = _newAddress;
    }

    /* this is the fallback function a fall back function is triggered if someone
    sends a function call or a transaction to this contract AND there is no function
    that corresponds to the name the callers is trying to execute 
    e.g. if someone tries to call HelloWorld() to this contract, which doesn't exist
    in this contract, then the fallback function will be called. 
    In this case, the fallback function will redirect the call to the functional contract
    Note: this is the standard fallback proxy function code; can just copy paste it*/
    fallback() external payable {
        address implementation = functionalAddress;
        require(functionalAddress != address(0));
        bytes memory data = msg.data; // msg.data is all info about the function call (called by the user)

        assembly {
            let result := delegatecall(
                gas(),
                implementation,
                add(data, 0x20), // add is another assembly function; this changes the format to something that delegate call can read
                mload(data), // mload is memory load
                0,
                0
            )
            let size := returndatasize()
            let ptr := mload(0x40) // ptr as in pointer
            returndatacopy(ptr, 0, size)
            switch result // result will either be 0 (as in function call failed), or 1 (function call success)
            case 0 {
                revert(ptr, size)
            } // revert if function call failed
            default {
                return(ptr, size)
            } // default means "else"; else return
        }
    }
}
