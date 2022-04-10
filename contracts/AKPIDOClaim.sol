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

	uint price = 200_000;

	bool canClaim;

	mapping(address => bool) redeemed;

	constructor(address _akp, address _ido) {
		akp = _akp;
		ido = _ido;
	}

	receive() external payable {}

	function setClaimStatus(bool _st) external onlyOwner{
		require(canClaim != _st, "Error: status Need not change");
		canClaim = _st;
	}


	function getIDOBalance(address addr) public view returns(uint256) {
		return IERC20(ido).balanceOf(addr);
	}

	function leftBalance() external view returns(uint) {
		return IERC20(akp).balanceOf(address(this));
	}


	function redeemAKP(uint amount) public  {
		address addr = msg.sender;
		uint bal = getIDOBalance(addr);
		require(canClaim, "Error: Cant Claim");
		require(bal >= amount * 1_000_000_000, "ERROR: Amount Error");
		require(!redeemed[addr], "ERROR: address has been redeemed");
	 	IERC20(akp).transfer(addr, amount * price);
	 	totalRedeemedTimes ++;
	 	totalRedeemedAmount += amount;
	 	redeemed[addr] = true;
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