// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EchainManager {
    mapping(address => uint256) public echainBalance;
    address public votingContract;
    address public ticketingContract;
    address public owner;

    event BalanceUpdated(address indexed user, uint256 newBalance);
    event Withdrawal(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    uint8 public votingPlatformFee=4;
    uint8 public ticketPlatformFee=5;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Only owner");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == votingContract || msg.sender == ticketingContract, "Not Authorized");
        _;
    }

    constructor() payable {
        owner = msg.sender; 
    }

    function setContracts(address _votingContract, address _ticketingContract) external onlyOwner {
        require(votingContract == address(0) && ticketingContract == address(0), "Contracts already set");
        require(isContract(_votingContract) && isContract(_ticketingContract), "Addresses must be contracts");
        
        votingContract = _votingContract;
        ticketingContract = _ticketingContract;
    }

    function updateBalance(address user, int256 delta) external onlyAuthorized {
        if (delta > 0) {
            echainBalance[user] += uint256(delta);
        } else {
            echainBalance[user] -= uint256(-delta);
        }
        emit BalanceUpdated(user, echainBalance[user]);
    }
    
    

    function withdrawBalance() external {
        uint256 balance = echainBalance[msg.sender];
        require(balance > 0, "No balance to withdraw");

        echainBalance[msg.sender] = 0;
        payable(msg.sender).transfer(balance);

        emit Withdrawal(msg.sender, balance);
    }

    function getBalance(address user) external view returns (uint256) {
        return echainBalance[user];
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No balance to withdraw");

        payable(owner).transfer(contractBalance);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    fallback() external payable {
        revert("Function does not exist");
    }

    receive() external payable { 
        echainBalance[msg.sender]=msg.value;
    }

    
    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
