//Crowdfunding
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

contract Crowdfunding {
    address payable public recipient;
    uint public goal;
    uint public deadline;
    mapping(address => uint) public contributions;
    uint public totalContributed;
    event FundTransfer(address contributor, uint amount);
    event GoalReached(uint totalAmount);
    event Refund(address contributor, uint amount);
    bool public goalReached;
    bool public refundAllowed;


    constructor(address payable _recipient, uint _goal, uint _deadline) public {
        recipient = _recipient;
        goal = _goal;
        deadline = _deadline;
        goalReached = false;
        refundAllowed = false;
    }

    function contribute() public payable {
        require(msg.value > 0);
        require(now <= deadline);
        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;
        emit FundTransfer(msg.sender, msg.value);
        if (totalContributed >= goal) {
            goalReached = true;
            emit GoalReached(totalContributed);
        }
    }

    function refund() public {
        require(refundAllowed);
        require(contributions[msg.sender] > 0);
        uint refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributed -= refundAmount;
        msg.sender.transfer(refundAmount);
        emit Refund(msg.sender, refundAmount);
    }

    function endCrowdfunding() public {
        require(goalReached || now > deadline);
        require(recipient != address(0));
        recipient.transfer(totalContributed);
    }

    function enableRefund() public {
        require(goalReached || now > deadline);
        refundAllowed = true;
    }
}
