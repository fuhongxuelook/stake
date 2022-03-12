// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AKPDistributor.sol";


contract StakeMonth is ERC20, Ownable {

    using SafeMath for uint256;

    address public constant SKPAddress = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;

    address public AKP;
    uint AKPDistributeAmount;


    AKPDistributor public distributor;

    event RedeemInfo(
        address indexed redeemAddr, 
        uint redeemTimes, 
        uint redeemNum,
        uint redeemTime
    );

    constructor(address _akp) ERC20("SKP-Stake", "SKP-Stake") {
        AKP = _akp;
        distributor = new AKPDistributor(_akp);
    }

    function Stake(uint256 amount) external {
        IERC20(SKPAddress).transferFrom(msg.sender, address(this), amount);
        safeMint(msg.sender, amount);
        return;
    }

    function Redeem() public returns(uint) {
        uint bal = balanceOf(msg.sender);
        safeBurn(msg.sender, bal);
        IERC20(SKPAddress).transfer(msg.sender, bal);

        return bal;
    }

    // ["0xd7336779179354A5E228586898d31c058795238c", "0xbec9536B52d7977AD2bE0842Db0F74a79c40F010"]
    // [1000, 1000]
    // default 9{0}
    function batchSafeMint(address[] memory addrs, uint[] memory amounts) internal {
        uint len = addrs.length;
        uint i;
        for(i; i < len; i ++) {
            safeMint(addrs[i], amounts[i]);
        }
    }

    // amount multi 9{0}
    function safeMint(address _account, uint256 _amount) internal {
        _mint(_account, _amount);
        distributor.setBalance(_account, balanceOf(_account));
    }

    function safeBurn(address _account, uint256 _amount) private {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
        distributor.setBalance(_account, balanceOf(_account));
    }

    function handleCalculate() public {
        uint256 AKPBalance = IERC20(AKP).balanceOf(address(this));

        // add locked
        if(AKPBalance >= AKPDistributeAmount) {
            bool success = IERC20(AKP).transfer(address(distributor), AKPBalance);
            if (success) {
                distributor.distributeAKPDividends(AKPBalance);
            }
        }
    }

    function claimAKPReward() public {
        uint256 AKPBalance = IERC20(AKP).balanceOf(address(this));

        // add locked
        if(AKPBalance >= AKPDistributeAmount) {
            bool success = IERC20(AKP).transfer(address(distributor), AKPBalance);
            if (success) {
                distributor.distributeAKPDividends(AKPBalance);
            }
        }

        uint withdrawAbleAmount = distributor.withdrawableDividendOf(msg.sender);
        require(withdrawAbleAmount > 0, "ERROR : insufficient Amount");

        distributor.processAccount(msg.sender);
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return distributor.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
        return distributor.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return distributor.balanceOf(account);
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return distributor.getNumberOfTokenHolders();
    }

}
