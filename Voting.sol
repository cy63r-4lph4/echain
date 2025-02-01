// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./EchainManager.sol";
contract Voting is Ownable{
    uint8 public platformFeePercentage;
    uint8 public unvoteFeePercentage;
    IERC20 public token;
    EchainManager public echainManager;

    constructor(address _tokenAddress, address payable _echainManager) Ownable(){
        token = IERC20(_tokenAddress);
        echainManager = EchainManager(_echainManager);
        platformFeePercentage = echainManager.votingPlatformFee();
        unvoteFeePercentage = echainManager.unvotePlatformFee();
    }

    struct Election {
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        string[] categories;
        bool privateElection;
        uint256 maxVotesPerVoter;
        mapping(string => bool) categoryExists;
        mapping(address => bool) whitelisted;
        mapping(string => string[]) candidates;
        mapping(string => mapping(string => bool)) candidateExists;
        mapping(string => mapping(string => uint256)) votes;
        mapping(address => uint256) userVotes;
        uint256 costPerVote;
        address payable organizer;
        uint256 organizerFund;
        bool isActive;
    }
    struct VoteData {
        uint256 electionId;
        address voter;
        string category;
        string candidate;
    }

    mapping(uint256 => Election) public elections;
    uint256 public electionCount;
    uint256 public fund;

    uint256 private unlocked = 1;
    modifier nonReentrant() {
        require(unlocked == 1, "Reentrancy Guard: reentrant call");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier onlyOrganizer(uint256 _electionId) {
        require(
            msg.sender == elections[_electionId].organizer,
            "Only the organizer can perform this action"
        );
        _;
    }

    modifier isElectionActive(uint256 _electionId) {
        require(elections[_electionId].isActive, "Election is not active");
        _;
    }

    modifier isElectionTime(uint256 _electionId) {
        require(
            block.timestamp >= elections[_electionId].startTime &&
                block.timestamp <= elections[_electionId].endTime,
            "Election is not active"
        );
        _;
    }

    modifier hasSufficientFunds(uint256 _electionId) {
        require(
            token.balanceOf(msg.sender) >= elections[_electionId].costPerVote,
            unicode"Insufficient CØRE balance to cast vote"
        );
        _;
    }

    modifier validCandidate(
        uint256 _electionId,
        string memory _category,
        string memory _candidate
    ) {
        require(
            elections[_electionId].candidateExists[_category][_candidate],
            "Invalid candidate for this category"
        );
        _;
    }

    modifier canVote(uint256 _electionId) {
        if (elections[_electionId].privateElection) {
            require(
                elections[_electionId].whitelisted[msg.sender],
                "You are not allowed to vote in this election"
            );
        }
        _;
    }

    modifier validCategory(uint256 _electionId, string memory _category) {
        require(
            elections[_electionId].categoryExists[_category],
            "Category does not exist"
        );
        _;
    }

    modifier voteLimitNotExceeded(uint256 _electionId) {
        require(
            elections[_electionId].userVotes[msg.sender] <
                elections[_electionId].maxVotesPerVoter,
            "Vote limit exceeded"
        );
        _;
    }

    event ElectionCreated(uint256 indexed electionId, string name);
    event CandidateAdded(
        uint256 indexed electionId,
        string category,
        string candidate
    );
    event VoteCast(VoteData vote);
    event VoteRevoked(
        uint256 indexed electionId,
        address voter,
        string category,
        string candidate
    );
    event ElectionClosed(uint256 indexed electionId);
    event FundsWithdrawn(
        uint256 indexed electionId,
        address organizer,
        uint256 amount
    );
    event WhitelistUpdated(uint256 electionId, address[] whitelistedAddresses);
    event BlacklistUpdated(uint256 electionId, address[] BlacklistedAddresses);
    event platformFundWithdrawn(uint256 amount);

    function createElection (
        string memory _name,
        string memory _description,
        uint256 _startTime,
        uint256 _endTime,
        string[] memory _categories,
        uint256 _costPerVote,
        uint _maxVotePerVoter
    ) public {
        require(
            echainManager.isOrganizer(msg.sender),
            "You are not an organizer"
        );
        electionCount++;
        Election storage election = elections[electionCount];
        election.name = _name;
        election.description = _description;
        election.startTime = _startTime;
        election.endTime = _endTime;
        election.categories = _categories;
        election.costPerVote = _costPerVote;
        election.isActive = true;
        election.organizer = payable(msg.sender);
        election.maxVotesPerVoter = _maxVotePerVoter;
        election.organizerFund = 0;

        emit ElectionCreated(electionCount, _name);
    }

    function addCandidates(
        uint256 _electionId,
        string memory _category,
        string[] memory _candidates
    ) public onlyOrganizer(_electionId) isElectionActive(_electionId) {
        Election storage election = elections[_electionId];
        uint256 candidatesLength = _candidates.length;
        for (uint256 i = 0; i < candidatesLength; i++) {
            string memory candidate = _candidates[i];
            if (!election.candidateExists[_category][candidate]) {
                election.candidateExists[_category][candidate] = true;
                election.candidates[_category].push(candidate);
                emit CandidateAdded(_electionId, _category, candidate);
            }
        }
    }

    function addWhitelist(
        uint256 _electionId,
        address[] memory _addresses
    ) public onlyOrganizer(_electionId) {
        elections[_electionId].privateElection = true;
        for (uint256 i = 0; i < _addresses.length; i++) {
            elections[_electionId].whitelisted[_addresses[i]] = true;
        }
        emit WhitelistUpdated(_electionId, _addresses);
    }

    function addBlacklistlist(
        uint256 _electionId,
        address[] memory _addresses
    ) public onlyOrganizer(_electionId) {
        elections[_electionId].privateElection = true;
        for (uint256 i = 0; i < _addresses.length; i++) {
            elections[_electionId].whitelisted[_addresses[i]] = false;
        }
        emit BlacklistUpdated(_electionId, _addresses);
    }

    function vote(
        uint256 _electionId,
        string memory _category,
        string memory _candidate
    )
        external
        payable
        nonReentrant
        isElectionActive(_electionId)
        isElectionTime(_electionId)
        hasSufficientFunds(_electionId)
        validCandidate(_electionId, _category, _candidate)
        canVote(_electionId)
        voteLimitNotExceeded(_electionId)
    {
        Election storage election = elections[_electionId];
        transferCORE(msg.sender, address(this), election.costPerVote);
        uint256 platformFee = (election.costPerVote * platformFeePercentage) /
            100;
        uint256 organizerShare = election.costPerVote - platformFee;

        fund += platformFee;
        election.organizerFund += organizerShare;
        election.votes[_category][_candidate]++;
        election.userVotes[msg.sender]++;

        VoteData memory voteData = VoteData(
            _electionId,
            msg.sender,
            _category,
            _candidate
        );

        emit VoteCast(voteData);
    }

    function unvote(
        uint256 _electionId,
        string memory _category,
        string memory _candidate
    )
        external
        nonReentrant
        isElectionActive(_electionId)
        validCandidate(_electionId, _category, _candidate)
    {
        Election storage election = elections[_electionId];
        require(election.userVotes[msg.sender] > 0, "You have not voted");
        require(
            election.votes[_category][_candidate] > 0,
            "No votes to revoke"
        );

        uint256 refund = (election.costPerVote * (100 - unvoteFeePercentage)) /
            100;
        uint256 platformFeeDelta = (election.costPerVote *
            (platformFeePercentage - unvoteFeePercentage)) / 100;
        uint256 organizerShareDelta = (election.costPerVote *
            (100 - platformFeePercentage)) / 100;

        election.votes[_category][_candidate]--;
        election.userVotes[msg.sender]--;
        fund -= platformFeeDelta;
        election.organizerFund -= organizerShareDelta;

        transferCORE(address(this), msg.sender, refund);
        emit VoteRevoked(_electionId, msg.sender, _category, _candidate);
    }

    function extendVoteDeadline(
        uint256 _endTime,
        uint256 _electionId
    ) external onlyOrganizer(_electionId) {
        elections[_electionId].endTime = _endTime;
    }

    function changeCostPerVote(
        uint256 _electionId,
        uint256 _costPerVote
    ) external onlyOrganizer(_electionId) isElectionActive(_electionId) {
        elections[_electionId].costPerVote = _costPerVote;
    }

    function withdrawFunds(
        uint256 _electionId
    ) public onlyOrganizer(_electionId) nonReentrant {
        Election storage election = elections[_electionId];
        require(
            !election.isActive,
            "Election must be closed to withdraw funds"
        );
        uint256 amount = election.organizerFund;
        require(amount > 0, "No funds available for withdrawal");

        election.organizerFund = 0;
        transferCORE(address(this), election.organizer, amount);
        emit FundsWithdrawn(_electionId, msg.sender, amount);
    }

    function closeElection(
        uint256 _electionId
    ) public onlyOrganizer(_electionId) {
        require(elections[_electionId].isActive, "The election is not active");
        elections[_electionId].isActive = false;
        emit ElectionClosed(_electionId);
    }

    receive() external payable {
        revert();
    }

    function getCategoryResults(
        uint256 _electionId,
        string memory _category
    )
        public
        view
        validCategory(_electionId, _category)
        returns (string[] memory, uint256[] memory)
    {
        Election storage election = elections[_electionId];
        string[] memory candidates = election.candidates[_category];
        uint256[] memory votes = new uint256[](candidates.length);

        for (uint256 i = 0; i < candidates.length; i++) {
            votes[i] = election.votes[_category][candidates[i]];
        }

        return (candidates, votes);
    }

    function getElectionDetails(
        uint256 _electionId
    )
        public
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            string[] memory,
            bool,
            uint256,
            uint256,
            uint256,
            address,
            bool
        )
    {
        Election storage election = elections[_electionId];
        return (
            election.name,
            election.description,
            election.startTime,
            election.endTime,
            election.categories,
            election.privateElection,
            election.maxVotesPerVoter,
            election.costPerVote,
            election.organizerFund,
            election.organizer,
            election.isActive
        );
    }

    function getElectionCandidates(
        uint256 _electionId,
        string memory _category
    )
        public
        view
        validCategory(_electionId, _category)
        returns (string[] memory)
    {
        return elections[_electionId].candidates[_category];
    }

    function getCandidateVotes(
        uint256 _electionId,
        string memory _category,
        string memory _candidate
    )
        public
        view
        validCategory(_electionId, _category)
        validCandidate(_electionId, _category, _candidate)
        returns (uint256)
    {
        return elections[_electionId].votes[_category][_candidate];
    }

    function getUserVoteCount(
        uint256 _electionId
    ) public view returns (uint256) {
        return elections[_electionId].userVotes[msg.sender];
    }

    function getElectionCount() public view returns (uint256) {
        return electionCount;
    }

    function getFund() public view returns (uint256) {
        return fund;
    }

    function getPlatformFeePercentage() public view returns (uint8) {
        return platformFeePercentage;
    }

    

    function transferCORE(address from, address to, uint256 _amount) internal {
        require(token.transferFrom(from, to, _amount), "CORE transfer failed");
    }

    function withdrawPlatformFund(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");

        transferCORE(address(this), owner(), amount);
        emit platformFundWithdrawn(amount);
    }
}
