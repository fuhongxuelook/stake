// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Distributor.sol";
import "./LPManager.sol";
import "./StakeInterface.sol";

// Mine AKP 
// Lock A Month
contract Mine is ERC20, Ownable, StakeInterface {

    using SafeMath for uint256;
    
    // BSC MAINNET
    // address public constant SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;
    // address public SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;

    // BSC TESTNET
    address public constant SKP = 0x60450e4F1246fedb38F83062BCB2BebAab6d110B;
    address public SHIB = 0x8a9424745056Eb399FD19a0EC26A14316684e274;

    // the akp address 
    // akp is benefits
    address public AKP;

    uint public AKPMintAmount;
    uint public SKPTotalStakedAmount;

    uint lastUpdateTime;
    uint timeFactor;
    uint rateBase = 100000;

    uint lastBlockNumber;

    uint staketime = 30 days;

    struct StakedItem {
        uint StartAt;
        uint Amount;
        bool Redeemed;
    }

    struct StakedList {
        StakedItem[] List;
    }

    mapping(address => StakedList) addrStakedList;

    Distributor public AkpDistributor;
    Distributor public ShibDistributor;

    constructor(address _akp) ERC20("SKP-Stake-Month", "SKP-Stake-Month") {
        AKP = _akp;
        AkpDistributor = new Distributor("AKP_Distributor", "AKP_Distributor", AKP);
        ShibDistributor = new Distributor("SHIB_Distributor", "SHIB_Distributor", SHIB);
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }   

    // transfor stake-token
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        // stake token
        super._transfer(from, to, amount);

        // gain akp reward token
        AkpDistributor.setBalance(from, balanceOf(from));
        ShibDistributor.setBalance(from, balanceOf(from));

        // gain shib reward token 
        AkpDistributor.setBalance(to, balanceOf(to));
        ShibDistributor.setBalance(to, balanceOf(to));
    }

    // need approve before stake
    function Stake(uint256 amount) external virtual override {
        // save gas
        address addr = msg.sender;

        IERC20(SKP).transferFrom(addr, address(this), amount);
        
        safeMint(addr, amount);

        SKPTotalStakedAmount = SKPTotalStakedAmount.add(amount);

        addrStakedList[addr].List.push(StakedItem(
            {StartAt: block.timestamp, Amount: amount, Redeemed: false})
        ); 
        emit STAKE(addr, amount, block.timestamp);
        return;
    }

    // redeem all staked SKP Token
    function Redeem() external virtual override returns(uint) {
        // save gas
        address addr = msg.sender;

        // amount this time can redeem
        uint amount = redeemFromList(addr);
        require(amount > 0, "Time Not Reached!");
        
        uint bal = balanceOf(addr);
        require(bal >= amount, "amount exceed balance");

        safeBurn(addr, amount);
        IERC20(SKP).transfer(addr, amount);
        emit REDEEM(addr, amount, block.timestamp);
        return amount;
    }

    // redeem from list
    function redeemFromList(address addr) public returns(uint amount) {
        //save gas
        StakedItem[] memory list = addrStakedList[addr].List;
        uint length = list.length;
        require(length > 0, "didnt stake");

        uint nowtime = block.timestamp;

        for(uint i; i < length; i ++) {
            if(
                list[i].StartAt + staketime <= nowtime && 
                !list[i].Redeemed
                ) {
                amount += list[i].Amount;
                addrStakedList[addr].List[i].Redeemed = true;
            }
        }
        return  amount;
    }

    // can redeem number
    function amountCanRedeem(address addr) public view returns(uint amount) {
        // save gas
        StakedItem[] memory list = addrStakedList[addr].List;
        
        uint length = list.length;
        require(length > 0, "didnt stake");

        uint nowtime = block.timestamp;

        for(uint i; i < length; i ++) {
            if(list[i].StartAt + staketime <= nowtime &&
                !list[i].Redeemed
                ) {
                amount += list[i].Amount; 
            }
        }
        return  amount;

    } 

    // set apy 
    function setTimeFactor(uint _tf) external onlyOwner {
        timeFactor = _tf;
    }

    function currentStaked() external view returns(uint stakedAmount) {
        return AkpDistributor.totalSupply();
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
    function checkout(uint akpReward) public {
        // need to wait next block 
        require(lastBlockNumber < block.number, "wait a minute");
        // add locked
        if(akpReward == 0) {
            return;
        }

        //deal akp reward
        bool success = IERC20(AKP).transfer(address(AkpDistributor), akpReward);
        if (success) {
            AKPMintAmount = AKPMintAmount.add(akpReward);
            AkpDistributor.distributeTokenDividends(akpReward);
        }

        // deal shib reward
        uint shibBalance = IERC20(SHIB).balanceOf(address(this));
        if(shibBalance == 0) {
            return;
        }
        success = IERC20(SHIB).transfer(address(ShibDistributor), shibBalance);
        if (success) {
            ShibDistributor.distributeTokenDividends(shibBalance);
        }


        lastBlockNumber = block.number;
    }

    // take back akp
    function takeBackAKP(uint amount) external onlyOwner {
        uint akpBal = IERC20(AKP).balanceOf(address(this));
        require(amount <= akpBal, "exceed balance");

        IERC20(AKP).transfer(msg.sender, amount);
    }   

    // function calculateStateReward() internal returns(uint256) {
    //     uint nowtime = block.timestamp;
    //     if(lastUpdateTime == 0) {
    //         lastUpdateTime = nowtime;
    //         return 0;
    //     }

    //     uint stakeTime = nowtime.sub(lastUpdateTime);
    //     uint skpBal = IERC20(SKP).balanceOf(address(this));

    //     lastUpdateTime = nowtime;
    //     return stakeTime.mul(skpBal).mul(timeFactor).div(rateBase);
    // }

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
