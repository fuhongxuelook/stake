// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface StakeInterface {

	event STAKE(address indexed staker, uint amount, uint timestamp);

    event REDEEM(address indexed redeemer, uint amount, uint timestamp);

	function Stake(uint amount) external;

	function Redeem() external returns(uint);

	function claimRewards() external;
}