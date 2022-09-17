pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED

contract gasOptimization {
     uint[] public arrayFunds;
    uint public totalFunds;

    constructor() {
        arrayFunds = [1,2,3,4,5,6,7,8,9,10,11,12,13];
    }

    function unsafe_inc(uint x) private pure returns (uint) {
        unchecked { return x + 1; }
    }

    function optionA() external { // reading and writing to blockchain increases gas cost. GAS: 85709
        for (uint i =0; i < arrayFunds.length; i++){
            totalFunds = totalFunds + arrayFunds[i];
        }
    }
    
    function optionB() external { // limiting writing with blockchain by creating temporary local variable. GAS: 81333 
        uint _totalFunds;
        for (uint i =0; i < arrayFunds.length; i++){
            _totalFunds = _totalFunds + arrayFunds[i];
        }
        totalFunds = _totalFunds;
    }

    function optionC() external { // limiting reading from blockchain by creating temporary array. GAS: 79301
        uint _totalFunds;
        uint[] memory _arrayFunds = arrayFunds;
        for (uint i =0; i < _arrayFunds.length; i++){
            _totalFunds = _totalFunds + _arrayFunds[i];
        }
        totalFunds = _totalFunds;
    }

    function optionD() external { // overridding safe arithmetical operation so save gas. ONLY USE WHEN YOU KNOW THAT OVERFLOW OR UNDERFLOW IS NOT REALISTIC. GAS: 78213
        uint _totalFunds;
        uint[] memory _arrayFunds = arrayFunds;
        for (uint i =0; i < _arrayFunds.length; i = unsafe_inc(i)){
            _totalFunds = _totalFunds + _arrayFunds[i];
        }
        totalFunds = _totalFunds;
    }
}