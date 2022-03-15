// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AKPDistributor.sol";

// state token
contract StakeMonth is ERC20, Ownable {

    using SafeMath for uint256;

    address public constant SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;

    address public AKP;

    uint public AKPMintAmount;
    uint public SKPTotalStakedAmount;

    uint lastUpdateTime;
    uint rateA = 10;
    uint rateBase = 1000;


    AKPDistributor public distributor;

    event STAKE(address indexed staker, uint amount, uint timestamp);

    event REDEEM(
        address indexed redeemer, 
        uint amount,
        uint timestamp
    );

    constructor(address _akp) ERC20("SKP-Stake", "SKP-Stake") {
        AKP = _akp;
        distributor = new AKPDistributor(_akp);
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    // need approve before stake
    function Stake(uint256 amount) external {
        // save gas
        address addr = msg.sender;
        checkout();
        IERC20(SKP).transferFrom(addr, address(this), amount);
        safeMint(addr, amount);
        SKPTotalStakedAmount = SKPTotalStakedAmount.add(amount);
        emit STAKE(addr, amount, block.timestamp);
        return;
    }

    // redeem all staked SKP Token
    function Redeem() public returns(uint) {
        checkout();
        // save gas
        address addr = msg.sender;
        uint bal = balanceOf(addr);
        safeBurn(addr, bal);
        IERC20(SKP).transfer(addr, bal);
        emit REDEEM(addr, bal, block.timestamp);
        return bal;
    }

    // set apy 
    function setRate(uint _rt) external onlyOwner {
        checkout();
        rateA = _rt;
    }

    // mint distributor token to receive AKP
    function safeMint(address _account, uint256 _amount) internal {
        _mint(_account, _amount);
        distributor.setBalance(_account, balanceOf(_account));
    }

    // burn distributor token
    function safeBurn(address _account, uint256 _amount) private {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
        distributor.setBalance(_account, balanceOf(_account));
    }


    // claim reward
    function claimAKPReward() public {
        uint withdrawAbleAmount = distributor.withdrawableDividendOf(msg.sender);
        require(withdrawAbleAmount > 0, "ERROR : insufficient Amount");

        distributor.processAccount(msg.sender);
    }

    // checkout period reward
    function checkout() internal {
        // add locked
        uint reward = calculateStateReward();
        bool success = IERC20(AKP).transfer(address(distributor), reward);
        if (success) {
            AKPMintAmount = AKPMintAmount.add(reward);
            distributor.distributeAKPDividends(reward);
        }
    }

    // calculate reward
    function calculateStateReward() internal returns(uint256) {
        uint nowtime = block.timestamp;
        if(lastUpdateTime == 0) {
            lastUpdateTime = nowtime;
            return 0;
        }

        uint stakeTime = nowtime.sub(lastUpdateTime);
        uint skpBal = IERC20(SKP).balanceOf(address(this));

        lastUpdateTime = nowtime;
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
