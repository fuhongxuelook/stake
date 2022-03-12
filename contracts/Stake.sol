// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AKPDistributor.sol";


contract StakeMonth is ERC20, Ownable {

    using SafeMath for uint256;

    address public constant SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;

    address public AKP;
    uint AKPDistributeAmount;
    uint lastUpdateTime;
    uint rateA = 10;
    uint rateBase = 1000;


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
        checkout();
        IERC20(SKP).transferFrom(msg.sender, address(this), amount);
        safeMint(msg.sender, amount);
        return;
    }

    function Redeem() public returns(uint) {
        checkout();
        uint bal = balanceOf(msg.sender);
        safeBurn(msg.sender, bal);
        IERC20(SKP).transfer(msg.sender, bal);
        return bal;
    }

    function setRate(uint _rt) external onlyOwner {
        checkout();
        rateA = _rt;
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


    function claimAKPReward() public {
        uint withdrawAbleAmount = distributor.withdrawableDividendOf(msg.sender);
        require(withdrawAbleAmount > 0, "ERROR : insufficient Amount");

        distributor.processAccount(msg.sender);
    }

    function checkout() internal {
        // add locked
        uint reward = calculateStateReward();
        bool success = IERC20(AKP).transfer(address(distributor), reward);
        if (success) {
            distributor.distributeAKPDividends(reward);
        }
    }

    function calculateStateReward() internal view returns(uint256) {
        if(lastUpdateTime == 0) {
            return 0;
        }

        uint stakeTime = block.timestamp.sub(lastUpdateTime);
        uint skpBal = IERC20(SKP).balanceOf(address(this));
        return stakeTime.mul(skpBal).mul(rateA).div(rateBase);


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
