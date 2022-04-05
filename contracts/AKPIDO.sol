// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// state token
contract AKPIDO is ERC20Pausable, Ownable {

	address recipient = 0x0cadE6e839026eC53CCDb17B43b79d5B9945fD16;
	
	uint constant PRECISION = 10 ** 18;
	uint public constant max = 400 * PRECISION;
	bool public status;

	mapping(address => bool) WL;

	constructor() ERC20("AKP-IDO", "AKP-IDO") {}

	// cant recevie bnb
	receive() external payable {
		require(false, "Cant Receive Ether");
	}

	// raise bnb
	function raise() external payable {
		uint amount = msg.value;
		uint totalMint = totalSupply();
		require(status || WL[msg.sender], "Cant raised");
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

	function pause() external onlyOwner {
    	_pause();
	}

	function addWL(address addr) public onlyOwner {
		require(!WL[addr], "Need Not To Add");
		WL[addr] = true;
	}

	function batchAddWL(address[] memory addrs) external onlyOwner {
		uint len = addrs.length;
		for(uint i; i < len; i ++) {
			WL[addrs[i]] = true;
		}
	}

	function giveAkp(address addr, uint amount) public onlyOwner {
		require(balanceOf(addr) == 0, "have given");
		_mint(addr, amount);
	}

	function batchGiveAkp(address[] memory addrs, uint[] memory amounts) external onlyOwner {
		uint len = addrs.length;
		for(uint i; i < len; i ++) {
			giveAkp(addrs[i], amounts[i]);
		}
	}
    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */

     function unpaused() external onlyOwner {
     	_unpause();
     }
    

	function start() external onlyOwner {
		status = true;
	}

	function end() external onlyOwner {
		status = false;
	}
}