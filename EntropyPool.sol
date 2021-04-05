pragma solidity ^0.5.10;

import './IERC20.sol';
import './SafeMath.sol';

contract EntropyPool{
    using SafeMath for uint256;

    address payable public owner;
    address payable public admin_fee;

    event CoinExchanged(address indexed addr, uint256 amount);
    event NewDeposit(uint256 amount);

    IERC20 usdt;
    IERC20 ndx;

    uint256 public usdt_pool_balance;
    uint256 public exchanged_tokens;
    uint40 public init_time;

    constructor() public {
        owner = msg.sender;
    
    	ndx = IERC20(0x563CB80479ca86cffC16160d80433B4Ceaac07d2); //NDX contract mainnet
    	//ndx = IERC20(0xB7eF020E3b15b2f4cD73fBbc03B7833688B9e5a1); //NDX contract shasta
    	usdt = IERC20(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C); //USDT contract mainnet
    	//usdt = IERC20(0xd98BF77669F75dfBFEe95643a313acD0Ba5E9b62); //USDT contract shasta
        admin_fee = address(0x2d097516aEd475dFB92bA611e1E5fd665e67dbB3);  //cold wallet mainnet
        //admin_fee = address(0x2d097516aEd475dFB92bA611e1E5fd665e67dbB3);  //cold wallet shasta 

	usdt_pool_balance = 0;
	exchanged_tokens = 0;
        init_time = uint40(block.timestamp);
    }


    function exchange(uint256 amount) public {

	uint256 ten = 10;
	uint256 ndx_base = ten.pwr(ndx.decimals()); 
	//1 ndx at least
    	require(amount >= ndx_base);
	uint256 base = 100;
	uint256 exchange_price =  base.add((block.timestamp.sub(init_time)).div(1 days));
	
	if(exchange_price > 1000)
		exchange_price = 1000;

	usdt_pool_balance = usdt.balanceOf(address(this));
        require(usdt_pool_balance >= amount.mul(exchange_price).div(1000));
	
	ndx.transferFrom(msg.sender, address(this), amount);

	ndx.burn(amount);

	exchanged_tokens = exchanged_tokens.add(amount);

	//99% transfer to sender
	uint256 interm = amount.mul(exchange_price);
        usdt.transfer(msg.sender, interm.div(1000).mul(99).div(100));

	//1% admin fee
        usdt.transfer(admin_fee, interm.div(1000).div(100));

	emit CoinExchanged(msg.sender, amount);
    }

    /*
        Only external call
    */
    function exchangeRate() view external returns(uint256 _exchange_price) {
	uint256 base = 100;
	uint256 exchange_price =  base.add((block.timestamp.sub(init_time)).div(1 days));
	return exchange_price;
    }
    function contractInfo() view external returns(uint256 _usdt_pool_balance, uint256 _exchanged_tokens,  uint40 _init_time) {
    	 uint256 balance = usdt.balanceOf(address(this));
	 return (balance, exchanged_tokens,  init_time);
    }
}
