// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SHIBDistributor.sol";

// state token
contract StakeMonth is ERC20, Ownable {

    using SafeMath for uint256;

    address public constant SKP = 0xCd79B84A0611971727928e1b7aEe9f8C61EDE777;
    address public SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;

    uint public SKPTotalStakedAmount;

    SHIBDistributor public ShibDistributor;

    event STAKE(address indexed staker, uint amount, uint timestamp);

    event REDEEM(
        address indexed redeemer, 
        uint amount,
        uint timestamp
    );

    constructor() ERC20("Pre-SKP-Stake", "Pre-SKP-Stake") {
        ShibDistributor = new SHIBDistributor();
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

    // mint AkpDistributor token to receive AKP
    function safeMint(address _account, uint256 _amount) internal {
        _mint(_account, _amount);
        ShibDistributor.setBalance(_account, balanceOf(_account));
    }

    // burn AkpDistributor token
    function safeBurn(address _account, uint256 _amount) private {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
        ShibDistributor.setBalance(_account, balanceOf(_account));
    }

    // claim shib and akp
    function claimRewards() public {
        claimSHIBReward();
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

}
