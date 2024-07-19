// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TwoExchangeFlashloanArbitrage is FlashLoanReceiverBase {
    using SafeERC20 for IERC20;

    address public uniswapRouter;
    address public sushiswapRouter;
    address public weth;
    address public owner;

    constructor(
        IPoolAddressesProvider _addressProvider,
        address _uniswapRouter,
        address _sushiswapRouter,
        address _weth
    ) FlashLoanReceiverBase(_addressProvider) {
        uniswapRouter = _uniswapRouter;
        sushiswapRouter = _sushiswapRouter;
        weth = _weth;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        uint256 amountToTrade = amounts[0];

        // Step 1: Swap ETH for DAI on Uniswap
        IERC20(assets[0]).approve(address(uniswapRouter), amountToTrade);
        uint256 wethAmount = swapOnUniswap(assets[0], weth, amountToTrade);

        // Step 2: Swap DAI for ETH on Sushiswap
        IERC20(weth).approve(address(sushiswapRouter), wethAmount);
        uint256 ethAmount = swapOnSushiswap(weth, assets[0], wethAmount);

        // // Step 3: Repay the loan
        uint256 amountOwing = amounts[0] + premiums[0];
        // require(ethAmount >= amountOwing, "Not enough profit");

        IERC20(assets[0]).approve(address(POOL), amountOwing);

        return true;
    }

    function swapOnUniswap(address fromToken, address toToken, uint256 amount) internal returns (uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(uniswapRouter);
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(
            amount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );

        return amounts[1];
    }

    function swapOnSushiswap(address fromToken, address toToken, uint256 amount) internal returns (uint256) {
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(sushiswapRouter);
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(
            amount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );

        return amounts[1];
    }

    function withdrawERC20(address tokenAddr, uint256 amount, address receiver) external onlyOwner(){
        IERC20(tokenAddr).transfer(receiver, amount);
    }

    function executeFlashloan(uint256 amount, address tokenAddress) external onlyOwner {
        address receiverAddress = address(this);
        address[] memory assets = new address[](1);
        assets[0] = tokenAddress; // DAI address for mainnet or testnet

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount; // Arbitrary amount

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0; // 0 means no debt (flashloan mode)

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }
}