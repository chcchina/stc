pragma solidity ^0.4.11;

contract LimitBalance {

  uint256 public limit;

  function LimitBalance(uint256 _limit) {
    limit = _limit;
  }

  /**
   * @dev Checks if limit was reached. Case true, it throws.
   */
  modifier limitedPayable() {
    require(this.balance <= limit);
    _;

  }

}
