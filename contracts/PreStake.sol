// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Distributor.sol";
import "./StakeInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// state token
contract PreStake is ERC20, Ownable, StakeInterface {

    using SafeMath for uint256;

    // bsc mainnet
    address public constant SKP = 0x83fDE646F6b89669070C9b3832ec2Cb37d66342F;
    address public SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;

    // bsc testnet
    // address public constant SKP = 0x60450e4F1246fedb38F83062BCB2BebAab6d110B;
    // address public SHIB = 0x8a9424745056Eb399FD19a0EC26A14316684e274;

    // header mine address
    address public Mine;
    uint public minimumStake = 1_000_000_000; // 10e

    uint public SKPTotalStakedAmount;
    bool canRedeem = false;

    Distributor public ShibDistributor;

    constructor() ERC20("Pre-SKP-Stake", "Pre-SKP-Stake") {
        ShibDistributor = new Distributor(
            "SHIB_Distributor",
            "SHIB_Distributor",
            SHIB
        );
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    // lock transfer
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(false, "cant transfer");

        super._transfer(from, to, amount);
    }

    function setMinimum(uint256 amount) external onlyOwner{
        minimumStake = amount;
    }

    function changeCanRedeem(bool st) external onlyOwner {
        require(canRedeem != st, "already set");
        canRedeem = st;
    }


    // need approve before stake
    // It can gain shib reward
    // so we mint token to gain shib
    function Stake(uint256 amount) external virtual override {
        // save gas
        address addr = msg.sender;
        checkout();

        require(amount >= minimumStake, "Amount not enough");

        IERC20(SKP).transferFrom(addr, address(this), amount);
        safeMint(addr, amount);

        SKPTotalStakedAmount = SKPTotalStakedAmount.add(amount);
        emit STAKE(addr, amount, block.timestamp);
        return;
    }

    // redeem all staked SKP Token
    function Redeem() external virtual override returns(uint) {
        require(canRedeem, "Cant Redeem");

        checkout();
        // save gas
        address addr = msg.sender;
        uint bal = balanceOf(addr);
        safeBurn(addr, bal);
        IERC20(SKP).transfer(addr, bal);
        emit REDEEM(addr, bal, block.timestamp);
        return bal;
    }

    // mint AkpDistributor token to receive AKP
    function safeMint(address _account, uint256 _amount) internal {
        _mint(_account, _amount);
        ShibDistributor.setBalance(_account, balanceOf(_account));
    }

    // burn AkpDistributor token
    function safeBurn(address _account, uint256 _amount) internal {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
        ShibDistributor.setBalance(_account, balanceOf(_account));
    }


    // claim SHIB reward
    function claimRewards() external virtual override {
        uint withdrawAbleAmount = ShibDistributor.withdrawableDividendOf(msg.sender);
        require(withdrawAbleAmount > 0, "Insufficient amount");

        ShibDistributor.processAccount(msg.sender);
    }

    // checkout period reward
    function checkout() public {
        // add locked
        uint shibBalance = IERC20(SHIB).balanceOf(address(this));
        if(shibBalance == 0) {
            return;
        }

        bool success = IERC20(SHIB).transfer(address(ShibDistributor), shibBalance);
        if (success) {
            ShibDistributor.distributeTokenDividends(shibBalance);
        }
    }

    function getSHIBTotalDistributed() external view returns (uint256) {
        return ShibDistributor.totalDividendsDistributed();
    }

    function withdrawableSHIBOf(address account) public view returns(uint256) {
        return ShibDistributor.withdrawableDividendOf(account);
    }

    function DistributorBalanceOf(address account) public view returns (uint256) {
        return ShibDistributor.balanceOf(account);
    }

    function getNumberOfDistributorHolders() external view returns(uint256) {
        return ShibDistributor.getNumberOfTokenHolders();
    }

    // off chain count stakers
    function migrate(address[] memory stakers) external onlyOwner {
        uint len = stakers.length;

        for(uint i; i < len; i ++ ) {
            _migrate(stakers[i]);
        }
    }

    // migrate to head mine
    function _migrate(address staker) internal {
        uint preStakeAmount = balanceOf(staker);

        IERC20(SKP).approve(Mine, preStakeAmount);
        StakeInterface(Mine).Stake(preStakeAmount);
        safeBurn(staker, preStakeAmount);
        IERC20(Mine).transfer(staker, preStakeAmount);
    }

    // set head mine address
    function setMineAddress(address mine) external onlyOwner {
        require(mine != address(0), "Cant be zero address");
        require(Mine != mine, "has been set");

        Mine = mine;
    }

    // free to migrate any mine
    // when stale is over, can migrate to any mine
    function freeMigrate(address mine, address staker) external {
        uint preStakeAmount = balanceOf(staker);

        IERC20(SKP).approve(mine, preStakeAmount);
        StakeInterface(mine).Stake(preStakeAmount);
        safeBurn(staker, preStakeAmount);
        IERC20(mine).transfer(staker, preStakeAmount);
    }

}
