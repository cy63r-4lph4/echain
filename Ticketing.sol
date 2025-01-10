// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./EchainManager.sol";
contract Ticketing is ERC721URIStorage, Ownable {
    
    using Counters for Counters.Counter;
    EchainManager public echainManager;
    uint8 public platformFeePercentage;

   

    struct Event {
        string name;
        string description;
        string venue;
        string metadata;
        uint256 date;
        uint256 price;
        uint256 maxTickets;
        uint256 ticketsSold;
        address payable organizer;
        uint256 organizerFund;
        bool isActive;
        mapping(address => bool) authorizedScanners;
    }

    Counters.Counter private _tokenIds;
    Counters.Counter private _eventIds;


    mapping(uint256 => Event) public events;
    mapping(uint256 => uint256) public ticketToEvent;
    mapping(uint256 => uint256) public resalePrices;
    mapping(uint256 => uint256) public checkedInTickets;


    event EventCreated(uint256 eventId, string name, string location, uint256 date, uint256 price, uint256 maxTickets);
    event TicketMinted(uint256 ticketId, uint256 eventId, address owner);
    event EventClosed(uint256 eventId);
    event TicketCheckedIn(uint256 ticketId, uint256 eventId, address attendee);
    event FundsWithdrawn(uint256 indexed eventId, address organizer, uint256 amount);
    event TicketTransferred(uint256 ticketId, address from, address to);
    event TicketResold(uint256 ticketId, address newOwner, uint256 resalePrice);
    event ResalePriceSet(uint256 ticketId, uint256 price);
    event TicketCheckedIn(uint256 ticketId, address owner,uint256 timestamp);
    event TicketBurned(uint256 ticketId, address owner);
    event AuthorizedScannerAdded(uint256 eventId, address scanner);


    constructor(address payable  _echainManager) ERC721("EventTicket", "ETKT") Ownable(){
        echainManager=EchainManager(_echainManager);
            platformFeePercentage=echainManager.ticketPlatformFee();

    }

    uint256 private unlocked = 1;
    modifier nonReentrant() {
        require(unlocked == 1, "Reentrancy Guard: reentrant call");
        unlocked = 0;
        _;
        unlocked = 1;
    }
    modifier eventExists(uint256 _eventId) {
        require(_eventId > 0 && _eventId <= _eventIds.current(), "Event does not exist");
        _;
    }
    

    modifier eventIsActive(uint256 _eventId) {
        require(events[_eventId].isActive, "Event is not active");
        _;
    }
    modifier hasSufficientFund(uint256 _eventId) {
        require(
            echainManager.getBalance(msg.sender) + msg.value >= events[_eventId].price,
            "Insufficient funds"
        );
         _;
    }
    modifier ticketIsAvailable(uint256 _eventId) {
        require(events[_eventId].ticketsSold<events[_eventId].maxTickets, "Tickets sold out.");
        _;
    }
    modifier onlyOrganizer(uint256 _eventId) {
        require(msg.sender == events[_eventId].organizer, "Only the organizer can perform this action");
        _;
    }
    modifier ticketNotCheckedIn(uint256 _ticketId) {
        require(checkedInTickets[_ticketId]==0, "Ticket already checked in");
        _;
    }

    function createEvent(
        string memory _name,
        string memory _description,
        string memory _venue,
        string memory _metadata,
        uint256 _date,
        uint256 _price,
        uint256 _maxTickets
    ) public {
        require(_date > block.timestamp, "Event date must be in the future");
        require(_maxTickets > 0, "Max tickets must be greater than zero");

        _eventIds.increment();
        uint256 newEventId = _eventIds.current();

        events[newEventId].name=_name;
        events[newEventId].description=_description;
        events[newEventId].venue=_venue;
        events[newEventId].metadata=_metadata;
        events[newEventId].date=_date;
        events[newEventId].price=_price;
        events[newEventId].maxTickets=_maxTickets;
        events[newEventId].organizer=payable (msg.sender);
        events[newEventId].organizerFund=0;
        events[newEventId].isActive=true;
        
            

        emit EventCreated(newEventId, _name, _venue, _date, _price, _maxTickets);
    }

    function mintTicket(uint256 _eventId ) external payable  eventExists(_eventId) eventIsActive(_eventId) ticketIsAvailable(_eventId)hasSufficientFund(_eventId){
        Event storage event_=events[_eventId];
        _tokenIds.increment();
        uint256 newTokenId=_tokenIds.current();
        int256 balanceDelta = int256(msg.value) - int256(event_.price);
        echainManager.updateBalance(msg.sender, balanceDelta);

        
        uint256 platformFee = (event_.price * platformFeePercentage) / 100;
        uint256 organizerShare = event_.price - platformFee;
        
        event_.organizerFund+=organizerShare;
        
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, event_.metadata);
        emit TicketMinted(newTokenId, _eventId, msg.sender);
    }

    function withdrawFunds(uint256 _eventId) public onlyOrganizer(_eventId) nonReentrant {
        Event storage event_ = events[_eventId];
        uint256 amount = event_.organizerFund;
        require(amount > 0, "No funds available for withdrawal");

        event_.organizerFund = 0;
        event_.organizer.transfer(amount);

        emit FundsWithdrawn(_eventId, msg.sender, amount);
    }

    function closeEvent(uint256 _eventId) external onlyOrganizer(_eventId) eventExists(_eventId) {
        events[_eventId].isActive = false;
        emit EventClosed(_eventId);
    }

    function transferTicket(uint256 ticketId, address to) external ticketNotCheckedIn(ticketId){
        require(to != address(0), "Invalid address: zero address");
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");
    
        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
    
        require(event_.isActive, "Cannot transfer tickets for inactive events");
    
        resalePrices[ticketId] = 0;
    
        _transfer(msg.sender, to, ticketId);
    
        emit TicketTransferred(ticketId, msg.sender, to);
    }

    function setResalePrice(uint256 ticketId, uint256 price) external ticketNotCheckedIn(ticketId){
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");
        require(price > 0, "Resale price must be greater than zero");
    
        resalePrices[ticketId] = price;
        emit ResalePriceSet(ticketId, price);
    }
    
    function buyResaleTicket(uint256 ticketId) external payable {
        uint256 resalePrice = resalePrices[ticketId];
        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
        require(event_.isActive, "Cannot process resale for inactive events");

        require(resalePrice > 0, "Ticket is not listed for resale");
        require(echainManager.getBalance(msg.sender) + msg.value >= resalePrice,
        "Insufficient funds");
        int256 balanceDelta = int256(msg.value) - int256(resalePrice);
        echainManager.updateBalance(msg.sender, balanceDelta);

    
        address seller = ownerOf(ticketId);
    
        uint256 platformFee = (resalePrice * platformFeePercentage) / 100;
        uint256 sellerShare = resalePrice - platformFee;
     
        echainManager.updateBalance(seller, int(sellerShare)); 
    
        resalePrices[ticketId] = 0;
        _transfer(seller, msg.sender, ticketId);
    
        emit TicketResold(ticketId, msg.sender, resalePrice);
    }

    function checkIn(uint256 ticketId) external  ticketNotCheckedIn(ticketId){
        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
        require(event_.authorizedScanners[msg.sender], "You are not an authorized scanner");
        require(event_.isActive, "Cannot check in for inactive events");
        require(ownerOf(ticketId) != address(0), "Ticket does not exist");
        checkedInTickets[ticketId] = block.timestamp;
        emit TicketCheckedIn(ticketId, ownerOf(ticketId),block.timestamp);
    }
    
    function burnTicket(uint256 ticketId) external {
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");
    
        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
        require(event_.isActive, "Cannot burn tickets for inactive events");
    
        require(checkedInTickets[ticketId]!=0, "Ticket must be checked in before burning");
    
        _burn(ticketId);
        delete ticketToEvent[ticketId];
        delete resalePrices[ticketId];
        delete checkedInTickets[ticketId];
    
        emit TicketBurned(ticketId, msg.sender);
    }

    function authorizeScanner(address scanner, bool isAuthorized, uint256 _eventId) external onlyOrganizer(_eventId) {
        Event storage event_=events[_eventId];
        require(event_.authorizedScanners[scanner] != isAuthorized, "Scanner is already in the desired state");
        event_.authorizedScanners[scanner] = isAuthorized;
        emit AuthorizedScannerAdded(_eventId,scanner);
    }
    
    
    

}
