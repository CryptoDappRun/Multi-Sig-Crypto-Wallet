// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TwoPersonMultisigWallet {
    address public person1;
    address public person2;
    uint public unlockAmount;

    bool public person1Approved = false;
    bool public person2Approved = false;

    // Event for when funds are withdrawn
    event FundsWithdrawn(address indexed to, uint amount);
    event Received(address from, uint amount);  // Event for receiving Ether

    // Constructor to initialize the two persons
    constructor(address _person1, address _person2) payable {
        require(msg.value > 0, "Initial deposit required");
        person1 = _person1;
        person2 = _person2;
        emit Received(msg.sender, msg.value);  // Emit event for initial deposit
    }

    // Modifier to restrict access to person1
    modifier onlyPerson1() {
        require(msg.sender == person1, "Only person1 can call this function");
        _;
    }

    // Modifier to restrict withdrawals to person1 or person2
    modifier onlyPerson1orPerson2(address _to) {
        require(_to == person1 || _to == person2, "Can only withdraw to person1 or person2");
        _;
    }

    // Function to approve the withdrawal by person1
    function approveByPerson1() external {
        require(msg.sender == person1, "Only person1 can approve");
        person1Approved = true;
    }

    // Function to approve the withdrawal by person2
    function approveByPerson2() external {
        require(msg.sender == person2, "Only person2 can approve");
        person2Approved = true;
    }

    // Function to withdraw funds (requires both approvals, and only person1 can call)
    // Also restricts the withdrawal to address person1 or person2
    function withdraw(address payable to, uint amount) 
        external 
        onlyPerson1 
        onlyPerson1orPerson2(to) 
    {
        require(person1Approved && person2Approved, "Both persons must approve the withdrawal");
        require(amount <= address(this).balance, "Insufficient balance");

        // Reset approvals after successful withdrawal
        person1Approved = false;
        person2Approved = false;

        to.transfer(amount);
        emit FundsWithdrawn(to, amount);
    }

    // Function to check the balance of the contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Special function to allow the contract to receive Ether
    receive() external payable {
        emit Received(msg.sender, msg.value);  // Emit event when Ether is received
    }
}
