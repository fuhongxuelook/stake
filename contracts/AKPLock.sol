//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract AKPLOCK is Ownable, ERC20 {

    using SafeMath for uint256;

    uint constant DECIMAL = 1_000_000_000;
    uint _supply = 1_000_000_000 * DECIMAL;
    uint maximumBurnAmount = _supply.sub(1_000_000 * DECIMAL);

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0x2d78e5905045b2B3bE56cA21DACdDF4a7a72a88a;

    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;

    bool swapping;

    IUniswapV2Router02 uniswapV2Router;
    address public  uniswapV2Pair;

    uint256 public burnFee = 1;
    uint256 public marketingFee = 4;

    uint256 swapTokensAtAmount = 100_000 * DECIMAL;

    uint256 totalFee = burnFee.add(marketingFee);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public BL;

    uint killBotPeriod = 60;
    uint killBotStart;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    constructor() ERC20("AKP", "AKP") {
        uniswapV2Router = IUniswapV2Router02(routerAddress);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        _mint(msg.sender, _supply);
        isExcludedFromFees[msg.sender] = true;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The swap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    // set distribute number
    function setSwapTokensAtAmount(uint _newAmount) public onlyOwner{
        swapTokensAtAmount = _newAmount;
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function batchChangeExFeeStatus(
        address[] memory addrs, 
        bool[] memory _sts) 
    external onlyOwner {
        uint lenAddr = addrs.length;
        for(uint256 i; i < lenAddr; i ++) {
            changeExcludeFeeStatus(addrs[i], _sts[i]);
        }
    }

    function changeExcludeFeeStatus(address addr, bool _st) public onlyOwner {
        require(isExcludedFromFees[addr] != _st, "Need No To Change");
        isExcludedFromFees[addr] = _st;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
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

        if(killBotStart == 0 && automatedMarketMakerPairs[to]) {
            killBotStart = block.timestamp;
        }

        // a period time buyer will add to Black list
        if(
            automatedMarketMakerPairs[from] && 
            killBotStart.add(killBotPeriod) >= block.timestamp 
        ) {
            BL[to] = true;
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() 
        ) {
            swapping = true;
            swapAndSendToFee(swapTokensAtAmount);
            swapping = false;
        }

        bool takeFee = !swapping;

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
            
            super._transfer(from, address(this), marketingAmount);

            amount = amount.sub(feeAmount);
        }

        super._transfer(from, to, amount);
       
    }

    function swapAndSendToFee(uint256 tokens) private  {

        if(tokens == 0) {
            return;
        }
        swapTokensForUSDT(tokens);
        uint256 usdtBalance = IERC20(USDT).balanceOf(address(this));

        (bool b, ) = USDT.call(abi.encodeWithSignature("transfer(address,uint256)", marketingWallet, usdtBalance));
        require(b, "call error");
    }


    function swapTokensForUSDT(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

   
}
