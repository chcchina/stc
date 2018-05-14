pragma solidity ^0.4.11;


import "../ownership/Ownable.sol";
import "../token/ERC20Basic.sol";

/** 
 * @title TokenDestructible:
 * @author Remco Bloemen <remco@stcline.com>
 * @dev Base contract that can be destroyed by owner. All funds in contract including
 * listed tokens will be sent to the owner.
 */
contract TokenDestructible is Ownable {

  function TokenDestructible() payable { } 

  function destroy(address[] tokens) onlyOwner {

    // Transfer tokens to owner
    for(uint256 i = 0; i < tokens.length; i++) {
      ERC20Basic token = ERC20Basic(tokens[i]);
      uint256 balance = token.balanceOf(this);
      token.transfer(owner, balance);
    }

    // Transfer Eth to owner and terminate contract
    selfdestruct(owner);
  }
}
