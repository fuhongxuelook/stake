// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract AkpIDOClaim is Ownable {

	address public akp;
	address public ido;

	uint public totalRedeemedTimes;
	uint public totalRedeemedAmount;

	constructor(address _akp, address _ido) {
		akp = _akp;
		ido = _ido;
	}

	receive() external payable {}


	function getIDOBalance(address addr) public view returns(uint256) {
		return IERC20(ido).balanceOf(addr);
	}

	function leftBalance() external view returns(uint) {
		return IERC20(akp).balanceOf(address(this));
	}


	function redeemAKP(uint amount) public  {
		address addr = msg.sender;
		uint bal = getIDOBalance(addr);
		require(bal >= amount * 1_000_000_000);
	 	IERC20(akp).transfer(addr, amount);
	 	totalRedeemedTimes ++;
	 	totalRedeemedAmount += amount;
	}

	function takeBack() external onlyOwner {
		uint amount = IERC20(ido).balanceOf(address(this));
		IERC20(akp).transfer(msg.sender, amount);
	}

	function takeBackAny(address token, address recipient) public onlyOwner {
		uint amount = IERC20(token).balanceOf(address(this));
	 	IERC20(token).transfer(recipient, amount);
	}

	
}