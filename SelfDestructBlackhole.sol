// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//0xc99c640F52D00c25d1b5B6Bb48EF668f99c880c9
// contract Force {/*

//                    MEOW ?
//          /\_/\   /
//     ____/ o o \
//   /~____  =ø= /
//  (______)__m_m)

// */}

contract SelfDestructingContract {


    function collect() public payable returns(uint) {
        return address(this).balance;
    }

    function seeBalance(address checkAddress) public view returns(uint) {
        return address(checkAddress).balance;
    }

    function selfDestroy() public {
        selfdestruct(0xc99c640F52D00c25d1b5B6Bb48EF668f99c880c9);
    }
}