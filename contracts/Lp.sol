// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUniswapV2Pair.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// state token
contract Lp is Ownable {

	using SafeMath for uint256;

	uint public factor = 2;

	address SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;

	mapping(address => bool) public SupportLp;

	constructor() {}


	function changeSupportLp(address _addr, bool _st) public onlyOwner {
		require(SupportLp[_addr] != _st, "Error: Need Not Execute!");
		SupportLp[_addr] = _st;
	}

	function setFactor(uint _newfactor) public onlyOwner {
		require(factor != _newfactor, "Error: Need Not Execute!");
		require(factor > 0, "factor can be zero");

		factor = _newfactor;
	}

	// get the number of skp in lp
	// address lp - lp token address
	// amount - lp amount
	function getLpTokenNumber(address lp, uint amount) internal view returns(uint) {
		require(amount > 0, "amount cant be zero");
		require(SupportLp[lp], "lp not support");

		IUniswapV2Pair pair = IUniswapV2Pair(lp);
		uint lpSupply = pair.totalSupply();
		require(lpSupply > 0, "lpSupply cant be zero");

		(uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
		address token0 = pair.token0();

		uint reserve = token0 == SKP ? reserve0 : reserve1;

		return reserve.mul(amount).div(lpSupply);
	}

	// number of staked SKP
	function getSkpNumberInSkp(address lp, uint amount) public view returns(uint) {
		uint lpSkpNumber = getLpTokenNumber(lp, amount);

		return factor.mul(lpSkpNumber);
	}

}