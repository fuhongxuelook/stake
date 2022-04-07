//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract AKP is Ownable, ERC20 {

    using SafeMath for uint256;

    uint constant DECIMAL = 1_000_000_000;
    uint _supply = 1_000_000_000 * DECIMAL;
    uint maximumBurnAmount = _supply.sub(1_000_000 * DECIMAL);

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0x8Edc1474720d6Eb0C13aaE87FBAB4abAD5b608Ab;

    // release token by time period
     //BSC TESTNET
    address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 uniswapV2Router;
    address public  uniswapV2Pair;

    uint256 public burnFee = 1;
    uint256 public marketingFee = 4;

    uint256 totalFee = burnFee.add(marketingFee);


    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public WL;
    mapping(address => bool) public BL;

    bool locker = true;
    uint killBotPeriod = 60;
    uint killBotStart;

    constructor() ERC20("AKP", "AKP") {
        uniswapV2Router = IUniswapV2Router02(routerAddress);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());


        _mint(msg.sender, _supply);
        isExcludedFromFees[msg.sender] = true;
        WL[msg.sender] = true;
    }

    function changeExcludeFeeStatus(address addr, bool _st) public {
        require(isExcludedFromFees[addr] != _st, "Need No To Change");
        isExcludedFromFees[addr] = _st;
    }

    function changeWLStatus(address addr, bool _st) public {
        require(WL[addr] != _st, "Need No To Change");
        WL[addr] = _st;
    }

    function changeBLStatus(address addr, bool _st) public {
        require(BL[addr] != _st, "Need No To Change");
        BL[addr] = _st;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    // open trade lock
    // just run once
    function openSale() external onlyOwner {
        require(locker, "AKP: Locker Has been Opened!");
        locker = false;
        killBotStart = block.timestamp;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        // ban black list trade
        require(!BL[from] && !BL[to], "Black list address");

        if(locker && !WL[from] && !WL[to]) {
            require(false, "Cant Trande");
        }

        // a period time buyer will add to Black list
        if(
            from == uniswapV2Pair && 
            killBotStart.add(killBotPeriod) <= block.timestamp && 
            !WL[to]
        ) {
            BL[to] = true;
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint burnedAmount = balanceOf(deadWallet);
            if(burnedAmount >= maximumBurnAmount && burnFee > 0) {
                burnFee = 0;
                totalFee = marketingFee;
            }

            uint feeAmount = amount.mul(totalFee).div(100);

            // preset 
            uint marketingAmount = feeAmount;
            if(burnFee > 0) {
                uint burnAmount = feeAmount.mul(burnFee).div(totalFee);
                super._transfer(from, deadWallet, burnAmount);

                marketingAmount = feeAmount.sub(burnAmount);
            }
            
            super._transfer(from, marketingWallet, marketingAmount);

            amount = amount.sub(feeAmount);
        }

        super._transfer(from, to, amount);
       
    }
   
}
