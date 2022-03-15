// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AKPDistributor.sol";
import "./SHIBDistributor.sol";
import "./LPManager.sol";
import "./StakeInterface.sol";

// state token
contract StakeMonth is ERC20, Ownable, StakeInterface {

    using SafeMath for uint256;

    address public constant SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;
    address public SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;
    address public AKP;

    uint public AKPMintAmount;
    uint public SKPTotalStakedAmount;

    uint lastUpdateTime;
    uint timeFactor;
    uint rateBase = 100000;


    AKPDistributor public AkpDistributor;
    SHIBDistributor public ShibDistributor;
    LPManager public LpManager;

    constructor(address _akp) ERC20("SKP-Stake", "SKP-Stake") {
        AKP = _akp;
        AkpDistributor = new AKPDistributor(_akp);
        ShibDistributor = new SHIBDistributor();
        LpManager = new LPManager(); 
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }   

    // transfor stake-token
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        super._transfer(from, to, amount);
        AkpDistributor.setBalance(from, balanceOf(from));
        ShibDistributor.setBalance(from, balanceOf(from));

        AkpDistributor.setBalance(to, balanceOf(to));
        ShibDistributor.setBalance(to, balanceOf(to));
    }

    // need approve before stake
    function Stake(uint256 amount) external virtual override {
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
    function Redeem() external virtual override returns(uint) {
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
    function setTimeFactor(uint _tf) external onlyOwner {
        checkout();
        timeFactor = _tf;
    }

    // mint AkpDistributor token to receive AKP
    function safeMint(address _account, uint256 _amount) internal {
        _mint(_account, _amount);
        AkpDistributor.setBalance(_account, balanceOf(_account));
        ShibDistributor.setBalance(_account, balanceOf(_account));
    }

    // burn AkpDistributor token
    function safeBurn(address _account, uint256 _amount) internal {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
        AkpDistributor.setBalance(_account, balanceOf(_account));
        ShibDistributor.setBalance(_account, balanceOf(_account));
    }

    // claim shib and akp
    function claimRewards() external virtual override {
        claimAKPReward();
        claimSHIBReward();
    }

    // claim AKP reward
    function claimAKPReward() internal {
        uint withdrawAbleAmount = AkpDistributor.withdrawableDividendOf(msg.sender);
        require(withdrawAbleAmount > 0, "ERROR : insufficient Amount");
        AkpDistributor.processAccount(msg.sender);
    }

    // claim AKP reward
    function claimSHIBReward() internal {
        uint withdrawAbleAmount = ShibDistributor.withdrawableDividendOf(msg.sender);
        if(withdrawAbleAmount > 0) {
            ShibDistributor.processAccount(msg.sender);
        } 
    }

    // checkout period reward
    function checkout() public {
        // add locked
        uint reward = calculateStateReward();
        if(reward == 0) {
            return;
        }
        bool success = IERC20(AKP).transfer(address(AkpDistributor), reward);
        if (success) {
            AKPMintAmount = AKPMintAmount.add(reward);
            AkpDistributor.distributeTokenDividends(reward);
        }

        uint shibBalance = IERC20(SHIB).balanceOf(address(this));
        if(shibBalance == 0) {
            return;
        }

        success = IERC20(SHIB).transfer(address(ShibDistributor), shibBalance);
        if (success) {
            ShibDistributor.distributeTokenDividends(shibBalance);
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
        return stakeTime.mul(skpBal).mul(timeFactor).div(rateBase);
    }

    function getAKPTotalDistributed() external view returns (uint256) {
        return AkpDistributor.totalDividendsDistributed();
    }

    function withdrawableAKPOf(address account) public view returns(uint256) {
        return AkpDistributor.withdrawableDividendOf(account);
    }

    function AkpDistributorBalanceOf(address account) public view returns (uint256) {
        return AkpDistributor.balanceOf(account);
    }

    function getNumberOfAkpDistributorHolders() external view returns(uint256) {
        return AkpDistributor.getNumberOfTokenHolders();
    }

}
