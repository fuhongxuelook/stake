// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract AkpReleaser is ERC20, Ownable {

    using SafeMath for uint256;

    address public AKP;

    bool public canRedeem;
    uint constant DECIMAL = 1_000_000_000;

    // last redeem date
    mapping (address => uint256) public nextRedeemDate;

    mapping (address => uint256) public initAKPBalance;

    // how many times did address withraw
    // total need 12 times; 
    mapping (address => uint256) public redeemTimes;

    uint ALL_REDEEM_TIMES = 11;

    // 1 month
    uint256 public redeemWaitTime = 30 days;

    event RedeemInfo(
        address indexed redeemAddr, 
        uint redeemTimes, 
        uint redeemNum,
        uint redeemTime
    );

    event StakeInfo(
        address indexed redeemAddr, 
        uint redeemTimes, 
        uint redeemNum,
        uint redeemTime
    );

    constructor(address akp) ERC20("AKP-Releaser", "AKP-Releaser") {
        AKP = akp;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function changeCanRedeem() public onlyOwner {
        require(!canRedeem, "already can redeem");
        canRedeem = true;
    }

    // redeem skp token
    function redeemAKP() public {
        address addr = msg.sender;

        uint bal = balanceOf(addr);
        uint times = redeemTimes[addr];

        uint initBalance = initAKPBalance[addr];
        uint redeemNumber;

        require(bal > 0 && times < 11, "error: not token to redeem"); 

        uint redeemDate = nextRedeemDate[addr];
        require(block.timestamp >= redeemDate, "ERROR: Need Wait Time");

        if(times == 0) {
            require(canRedeem, "ERROR: Redeem ERROR");
            require(bal == initBalance, "ERROR: Number ERROR");
            redeemNumber = initBalance.mul(5).div(100);
        } else if(times < 6) {
            // all 18 month
            // last month redeem all
            redeemNumber = initBalance.mul(8).div(100);
        } else if (times < 10){
            redeemNumber = initBalance.mul(11).div(100);
        } else {
            redeemNumber = bal;
        }

        require(redeemNumber <= bal, "error: insufficient AKP amount");

        IERC20(AKP).transfer(addr, redeemNumber);

        redeemTimes[addr] += 1;
        nextRedeemDate[addr] = block.timestamp + redeemWaitTime;

        safeBurn(addr, redeemNumber);

        emit StakeInfo(addr, times, redeemNumber, block.timestamp);
    }

    function changeRedeemWaitTime(uint newTime) public onlyOwner {
        redeemWaitTime = newTime;
    }

    // ["0xd7336779179354A5E228586898d31c058795238c", "0xbec9536B52d7977AD2bE0842Db0F74a79c40F010"]
    // [1000, 1000]
    // default 9{0}
    function batchSafeMint(address[] memory addrs, uint[] memory amounts) public onlyOwner {
        uint len = addrs.length;
        uint i;
        for(i; i < len; i ++) {
            safeMint(addrs[i], amounts[i]);
        }
    }

    // amount multi 9{0}
    function safeMint(address _account, uint256 _amount) public onlyOwner {
        _amount = _amount * DECIMAL;

        uint akpBalance = IERC20(AKP).balanceOf(address(this));
        
        require(totalSupply().add(_amount) <= akpBalance, "ERROR: MINT exceed!");

        _mint(_account, _amount);
        initAKPBalance[_account] = initAKPBalance[_account].add(_amount);
    }

    function safeBurn(address _account, uint256 _amount) private {
        uint bal = balanceOf(_account);
        require(bal >= _amount, "burn amount exceed");
        _burn(_account, _amount);
    }

}
