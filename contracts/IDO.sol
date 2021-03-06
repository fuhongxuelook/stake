// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// state token
contract IDO is ERC20, Ownable {

	address recipient = 0x0cadE6e839026eC53CCDb17B43b79d5B9945fD16;
	
	uint constant PRECISION = 10 ** 18;
	uint public constant max = 400 * PRECISION;
	bool public status;

	constructor() ERC20("AKP-IDO", "AKP-IDO") {}

	// cant recevie bnb
	receive() external payable {
		require(false, "Cant Receive Ether");
	}

	// raise bnb
	function raise() external payable {
		uint amount = msg.value;
		uint totalMint = totalSupply();
		require(status, "Cant raised");
		require(amount >= 0.1 ether && amount <= 5 ether, "ERROR: BNB Number Error");
		require(balanceOf(msg.sender) == 0, "Error:has been raised!");
		require(totalMint <= max, "Raised enougn" );

		if (totalMint + amount > max) {
			uint canTake = max - totalMint;
			payable(msg.sender).transfer(amount - canTake);
			amount = canTake;
		}

		payable(recipient).transfer(msg.value);	

		_mint(msg.sender, amount);
	}

	function start() external onlyOwner {
		status = true;
	}

	function end() external onlyOwner {
		status = false;
	}
}