// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract AkpStake is Ownable {

	address public akp;

	constructor(address _akp) {
		akp = _akp;
	}

	receive() external payable {}


	function getAkpBalance() public view returns(uint256) {
		return IERC20(akp).balanceOf(address(this));
	}


	function withdrawAKP() public onlyOwner {
		uint amount = getAkpBalance();
	 	IERC20(akp).transfer(owner(), amount);
	}


	function withdrawAnyToken(address token, address recipient) public onlyOwner {
		uint amount = IERC20(token).balanceOf(address(this));
	 	IERC20(token).transfer(recipient, amount);
	}

	
}