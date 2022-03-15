// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DividendPayingToken.sol";
import "./IterableMapping.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// reward token 
contract SHIBDistributor is Ownable, DividendPayingToken {

    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;

    mapping (address => bool) public excludedFromDividends;

    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);

    event Claim(address indexed account, uint256 amount);

    address public SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;

    constructor() DividendPayingToken("SHIB_Distributor", "SHIB_Distributor", SHIB) {
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }


    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }


    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function setBalance(address account, uint256 newBalance) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }

        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
    }


    function processAccount(address account) public onlyOwner  {
        _withdrawDividendOfUser(account);
    }
}