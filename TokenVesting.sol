pragma solidity ^0.5.10;
/** 

 * @title TokenVesting

 * @dev A token holder contract that can release its token balance gradually like a

 * typical vesting scheme.

 */

import './SafeMath.sol';
import './IERC20.sol';

contract TokenVesting {

  using SafeMath for uint256;

  event Released(uint256 amount);

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public start;

  uint256 public ndx_withdrawed;

  IERC20 ndx;

  /**

   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the

   * _beneficiary, gradually in a linear fashion until token balance is 0. By then all

   * of the balance will have vested.

   */

  constructor(

    address _beneficiary

  )

    public

  {

    require(_beneficiary != address(0));

    beneficiary = _beneficiary;

    start = block.timestamp;

    ndx_withdrawed = 0;

    ndx = IERC20(0x563CB80479ca86cffC16160d80433B4Ceaac07d2); //NDX contract mainnet
    //ndx = IERC20(0xB7eF020E3b15b2f4cD73fBbc03B7833688B9e5a1); //NDX contract shasta
    
  }

  /**

   * @notice Transfers vested tokens to beneficiary.

   * Duration is 180 days and released everyday equally.

   */

  function withdraw() public {

    uint256 balance = ndx.balanceOf(address(this));

    require(balance  > 0);

    uint256 payout = (block.timestamp.sub(start)).div(1 days).mul(50000000000000).div(180).sub(ndx_withdrawed);
    
    if(payout > balance)
    	payout = balance;

    require(payout > 0);

    ndx_withdrawed = ndx_withdrawed.add(payout);

    ndx.transfer(beneficiary, payout);

    emit Released(payout);
  }

}
