// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EchainManager {
    address public votingContract;
    address public ticketingContract;
    address public owner;

    mapping(address => bool) private Organizers;

    uint8 public votingPlatformFee = 4;
    uint8 public unvotePlatformFee = 2;
    uint8 public maxCategoriesPerEvent = 5;

    uint8 public ticketingPlatformFee = 5;

    event OrganizerRegistered(address indexed organizer);
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );
    event ContractsSet(address votingContract, address ticketingContract);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Only owner");
        _;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == votingContract || msg.sender == ticketingContract,
            "Not Authorized"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setContracts(
        address _votingContract,
        address _ticketingContract
    ) external onlyOwner {
        require(
            votingContract == address(0) && ticketingContract == address(0),
            "Contracts already set"
        );
        require(
            isContract(_votingContract) && isContract(_ticketingContract),
            "Addresses must be contracts"
        );

        votingContract = _votingContract;
        ticketingContract = _ticketingContract;

        emit ContractsSet(_votingContract, _ticketingContract);
    }

    function registerOrganizer() external {
        require(!Organizers[msg.sender], "Already an organizer");
        Organizers[msg.sender] = true;
        emit OrganizerRegistered(msg.sender);
    }

    function isOrganizer(address user) external view returns (bool) {
        return Organizers[user];
    }


    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    function updateVotingPlatformFee(uint8 newFee) public{
        require(newFee<10,"Platform fee must be less than 10%");
        votingPlatformFee=newFee;
    }
    function updateUnvotePlatformFee(uint8 newFee) public{
        require(newFee<10,"Platform fee must be less than 10%");
        unvotePlatformFee=newFee;
    }
    function updateTicketingPlatformFee(uint8 newFee) public{
        require(newFee<10,"Platform fee must be less than 10%");
        ticketingPlatformFee=newFee;
    }

    fallback() external {
        revert("Function does not exist");
    }
    receive() external payable{
        revert();
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
