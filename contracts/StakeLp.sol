// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AKPDistributor.sol";
import "./SHIBDistributor.sol";
import "./LPManager.sol";
import "./StakeLpInterface.sol";

// stake lp and redeem lp
// stake lp can't get SHIB
contract StakeLp is ERC20, Ownable, StakeLpInterface {

    using SafeMath for uint256;

    address public constant SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;
    address public AKP;

    uint public AKPMintAmount;
    uint public SKPTotalStakedAmount;

    uint lastUpdateTime;
    uint timeFactor;
    uint rateBase = 100000;


    AKPDistributor public AkpDistributor;
    LPManager public LpManager;

    constructor(address _akp) ERC20("SKP-LP-Stake", "SKP-LP-Stake") {
        AKP = _akp;
        AkpDistributor = new AKPDistributor(_akp);
        LpManager = new LPManager(); 
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    // lock transfer
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(false, "cant transfer");
        super._transfer(from, to, amount);
    }

    // need be approved
    function Stake(address lp, uint amount) external virtual override {
        uint lpReflectSkpAmount = LpManager.getSkpNumberInSkp(lp, amount);
        require(lpReflectSkpAmount > 0, "skp amount cant be zero");

        address addr = msg.sender;
        checkout();
        IERC20(lp).transferFrom(addr, address(this), amount);
        safeMint(addr, lpReflectSkpAmount);
        SKPTotalStakedAmount = SKPTotalStakedAmount.add(lpReflectSkpAmount);
        emit STAKE(addr, lpReflectSkpAmount, block.timestamp);
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

    function isSupportLp(address lp) public view returns(bool) {
        return LpManager.isSupportLp(lp);
    }

    function changeLpSupport(address lp, bool _st) external onlyOwner {
        LpManager.changeSupportLp(lp, _st);
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
    }

    // burn AkpDistributor token
    function safeBurn(address _account, uint256 _amount) internal {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
        AkpDistributor.setBalance(_account, balanceOf(_account));
    }

    // claim akp
    function claimRewards() external virtual override {
        claimAKPReward();
    }

    // claim AKP reward
    function claimAKPReward() internal {
        uint withdrawAbleAmount = AkpDistributor.withdrawableDividendOf(msg.sender);
        require(withdrawAbleAmount > 0, "ERROR : insufficient Amount");
        AkpDistributor.processAccount(msg.sender);
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
