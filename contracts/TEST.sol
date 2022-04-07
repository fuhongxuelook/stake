// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// state token
contract TEST is ERC20 {

	constructor() ERC20("TEST", "TEST") {
		_mint(msg.sender, 100_000_000_000_000);
	}

}
