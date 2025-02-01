// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./EchainManager.sol";                                       

contract Ticketing is ERC721URIStorage, Ownable {
    struct TicketCategory {
        string name;
        uint256 price;
        uint256 available;
    }

    struct Event {
        string name;
        string venue;
        string metadata;
        uint256 date;
        uint256 organizerFund;
        uint8 categoryCount;
        address payable organizer;
        bool isActive;
        bool isRefundable;
        bool archived;
        mapping(address => bool) authorizedScanners;
        mapping(uint8 => TicketCategory) ticketCategories;
        mapping(uint256 => uint8) ticketToCategory;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _eventIds;

    uint8 public platformFeePercentage;
    uint8 maxCategoriesPerEvent;

    mapping(uint256 => Event) public events;
    mapping(uint256 => uint256) public ticketToEvent;
    mapping(uint256 => uint256) public resalePrices;
    mapping(uint256 => uint256) public checkedInTickets;
    mapping(address => bool) public blacklistedUsers;

    event EventCreated(
        uint256 eventId,
        string name,
        string location,
        uint256 date
    );
    event TicketMinted(uint256 ticketId, uint256 eventId, address owner);
    event EventClosed(uint256 eventId);
    event TicketCheckedIn(uint256 ticketId, uint256 eventId, address attendee);
    event FundsWithdrawn(
        uint256 indexed eventId,
        address organizer,
        uint256 amount
    );
    event TicketTransferred(uint256 ticketId, address from, address to);
    event TicketResold(uint256 ticketId, address newOwner, uint256 resalePrice);
    event ResalePriceSet(uint256 ticketId, uint256 price);
    event TicketCheckedIn(uint256 ticketId, address owner, uint256 timestamp);
    event TicketBurned(uint256 ticketId, address owner);
    event AuthorizedScannerUpdated(
        uint256 eventId,
        address scanner,
        bool Authorized
    );
    event userBlacklisted(address user);
    event attendeeRefunded(address attendee, uint256 amount);
    event categoryDetailsUpdated(
        uint256 event_,
        uint8 category,
        TicketCategory tk
    );
    event eventNameUpdated(string newName);
    event platformFundWithdrawn(uint256 amount);
    event eventDateUpdated(uint256 newDate);
    event eventMetadataUpdated(string newMetadata);
    event platformFeeUpdated(uint8 newFee);
    event maxCategoriesUpdated(uint8 newLimit);
    event eventVenueUpdated(string newVenue);

    IERC20 public immutable token;
    EchainManager public echainManager;

    constructor(address _tokenAddress, address payable _echainManager) ERC721("EventTicket", "ETKT") Ownable() {
        echainManager=EchainManager(_echainManager);
        platformFeePercentage = echainManager.ticketingPlatformFee();
        maxCategoriesPerEvent = echainManager.maxCategoriesPerEvent();
        token = IERC20(_tokenAddress);
    }

    uint256 private unlocked = 1;
    modifier nonReentrant() {
        require(unlocked == 1, "Reentrancy Guard: reentrant call");
        unlocked = 0;
        _;
        unlocked = 1;
    }
    modifier eventExists(uint256 _eventId) {
        require(
            _eventId > 0 && _eventId <= _eventIds.current(),
            "Event does not exist"
        );
        _;
    }
    modifier eventIsActive(uint256 _eventId) {
        require(events[_eventId].isActive, "Event is not active");
        _;
    }
    modifier hasSufficientFund(uint256 _eventId, uint8 _categoryId) {
        require(
            token.balanceOf(msg.sender) >=
                events[_eventId].ticketCategories[_categoryId].price,
            unicode"Insufficient CØRE balance to cast vote"
        );
        _;
    }
    modifier ticketIsAvailable(uint256 _eventId, uint8 _categoryId) {
        require(
            events[_eventId].ticketCategories[_categoryId].available > 0,
            "Tickets sold out."
        );
        _;
    }
    modifier onlyOrganizer(uint256 _eventId) {
        require(
            msg.sender == events[_eventId].organizer,
            "Only the organizer can perform this action"
        );
        _;
    }
    modifier ticketNotCheckedIn(uint256 _ticketId) {
        require(checkedInTickets[_ticketId] == 0, "Ticket already checked in");
        _;
    }
    modifier notBlacklisted() {
        require(!blacklistedUsers[msg.sender], "You are blacklisted");
        _;
    }

    function createEvent(
        string memory _name,
        string memory _venue,
        string memory _metadata,
        uint256 _date,
        string[] memory _categoryNames,
        uint256[] memory _categoryPrices,
        uint256[] memory _categoryAvailability
    ) public {
        require(
            echainManager.isOrganizer(msg.sender),
            "You are not an organizer"
        );
        require(_date > block.timestamp, "Event date must be in the future");
        require(
            _categoryNames.length == _categoryPrices.length &&
                _categoryPrices.length == _categoryAvailability.length,
            "Mismatch in category details"
        );

        _eventIds.increment();
        uint256 newEventId = _eventIds.current();
        Event storage newEvent = events[newEventId];
        newEvent.name = _name;

        newEvent.venue = _venue;
        newEvent.metadata = _metadata;
        newEvent.date = _date;
        newEvent.organizer = payable(msg.sender);
        newEvent.organizerFund = 0;
        newEvent.isActive = true;

        for (uint8 i = 0; i < _categoryNames.length; i++) {
            require(
                newEvent.categoryCount <= maxCategoriesPerEvent,
                "Max category limit exceeded"
            );
            newEvent.ticketCategories[i] = TicketCategory({
                name: _categoryNames[i],
                price: _categoryPrices[i],
                available: _categoryAvailability[i]
            });
            newEvent.categoryCount++;
        }

        emit EventCreated(newEventId, _name, _venue, _date);
    }

    function mintTicket(
        uint256 _eventId,
        uint8 _categoryId
    )
        external
        eventExists(_eventId)
        eventIsActive(_eventId)
        ticketIsAvailable(_eventId, _categoryId)
        hasSufficientFund(_eventId, _categoryId)
    {
        Event storage event_ = events[_eventId];
        require(event_.date > block.timestamp, "Event has ended");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        uint256 ticketPrice = event_.ticketCategories[_categoryId].price;

        uint256 platformFee = (ticketPrice * platformFeePercentage) / 100;
        uint256 organizerShare = ticketPrice - platformFee;

        transferCORE(msg.sender, address(this), ticketPrice);

        event_.organizerFund += organizerShare;
        event_.ticketCategories[_categoryId].available--;
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, event_.metadata);

        ticketToEvent[newTokenId] = _eventId;
        event_.ticketToCategory[newTokenId] = _categoryId;

        emit TicketMinted(newTokenId, _eventId, msg.sender);
    }

    function withdrawFunds(
        uint256 _eventId,
        uint256 _amount
    ) public onlyOrganizer(_eventId) nonReentrant {
        Event storage event_ = events[_eventId];
        require(
            _amount > 0 && _amount <= event_.organizerFund,
            "Invalid amount"
        );
        require(event_.isActive, "Cannot withdraw funds for inactive events");
        event_.organizerFund -= _amount;
        event_.isRefundable = false;
        require(token.transfer(msg.sender, _amount), "Token transfer failed");

        emit FundsWithdrawn(_eventId, msg.sender, _amount);
    }

    function closeEvent(
        uint256 _eventId
    ) external onlyOrganizer(_eventId) eventExists(_eventId) {
        Event storage event_ = events[_eventId];
        require(event_.isActive, "Event is already closed");
        require(event_.date < block.timestamp, "Event has not ended");
        event_.archived = false;
        events[_eventId].isActive = false;
        emit EventClosed(_eventId);
    }

    function transferTicket(
        uint256 ticketId,
        address to
    ) external ticketNotCheckedIn(ticketId) {
        require(to != address(0), "Invalid address: zero address");
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");

        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];

        require(event_.isActive, "Cannot transfer tickets for inactive events");

        resalePrices[ticketId] = 0;

        _transfer(msg.sender, to, ticketId);

        emit TicketTransferred(ticketId, msg.sender, to);
    }

    function setResalePrice(
        uint256 ticketId,
        uint256 price
    ) external ticketNotCheckedIn(ticketId) {
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");
        require(price > 0, "Resale price must be greater than zero");

        resalePrices[ticketId] = price;
        emit ResalePriceSet(ticketId, price);
    }

    function buyResaleTicket(uint256 ticketId) external payable nonReentrant {
        uint256 resalePrice = resalePrices[ticketId];
        require(
            token.balanceOf(msg.sender) >= resalePrice,
            "Insufficient funds"
        );
        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
        require(event_.isActive, "Cannot process resale for inactive events");

        require(resalePrice > 0, "Ticket is not listed for resale");

        address seller = ownerOf(ticketId);
        transferCORE(msg.sender, address(this), resalePrice);

        uint256 platformFee = (resalePrice * platformFeePercentage) / 100;
        uint256 sellerShare = resalePrice - platformFee;

        resalePrices[ticketId] = 0;
        _transfer(seller, msg.sender, ticketId);
        payable(seller).transfer(sellerShare);

        emit TicketResold(ticketId, msg.sender, resalePrice);
    }

    function checkIn(uint256 ticketId) external ticketNotCheckedIn(ticketId) {
        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
        require(
            event_.authorizedScanners[msg.sender],
            "You are not an authorized scanner"
        );
        require(event_.isActive, "Cannot check in for inactive events");
        require(ownerOf(ticketId) != address(0), "Ticket does not exist");
        checkedInTickets[ticketId] = block.timestamp;
        emit TicketCheckedIn(ticketId, ownerOf(ticketId), block.timestamp);
    }

    function burnTicket(uint256 ticketId) external {
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");

        uint256 eventId = ticketToEvent[ticketId];
        Event storage event_ = events[eventId];
        require(
            event_.date < block.timestamp,
            "Cannot burn tickets at this time"
        );

        _burn(ticketId);
        delete ticketToEvent[ticketId];
        delete resalePrices[ticketId];
        delete checkedInTickets[ticketId];

        emit TicketBurned(ticketId, msg.sender);
    }

    function authorizeScanner(
        address scanner,
        bool isAuthorized,
        uint256 _eventId
    ) external onlyOrganizer(_eventId) {
        Event storage event_ = events[_eventId];
        require(
            event_.authorizedScanners[scanner] != isAuthorized,
            "Scanner is already in the desired state"
        );
        event_.authorizedScanners[scanner] = isAuthorized;
        emit AuthorizedScannerUpdated(_eventId, scanner, isAuthorized);
    }

    function getTicketCategories(
        uint256 _eventId
    ) external view returns (TicketCategory[] memory) {
        Event storage event_ = events[_eventId];
        TicketCategory[] memory categories = new TicketCategory[](
            event_.categoryCount
        );

        for (uint8 i = 0; i < event_.categoryCount; i++) {
            categories[i] = event_.ticketCategories[i];
        }
        return categories;
    }

    function withdrawPlatformFund(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");

        transferCORE(address(this), owner(), amount);
        emit platformFundWithdrawn(amount);
    }

  

    function updateMaxCategoriesPerEvent(uint8 newLimit) external onlyOwner {
        maxCategoriesPerEvent = newLimit;
        emit maxCategoriesUpdated(newLimit);
    }

    function updateEventMetadata(
        uint256 eventId,
        string memory newMetadata
    ) external onlyOrganizer(eventId) {
        events[eventId].metadata = newMetadata;
        emit eventMetadataUpdated(newMetadata);
    }

    function updateEventDate(
        uint256 eventId,
        uint256 newDate
    ) external onlyOrganizer(eventId) {
        require(newDate > block.timestamp, "Event date must be in the future");
        events[eventId].date = newDate;
        emit eventDateUpdated(newDate);
    }

    function updateEventVenue(
        uint256 eventId,
        string memory newVenue
    ) external onlyOrganizer(eventId) {
        events[eventId].venue = newVenue;
        emit eventVenueUpdated(newVenue);
    }

    function updateEventName(
        uint256 eventId,
        string memory newName
    ) external onlyOrganizer(eventId) {
        events[eventId].name = newName;
        emit eventNameUpdated(newName);
    }

    function updateCategoryDetails(
        uint256 eventId,
        uint8 categoryId,
        string memory newName,
        uint256 newPrice,
        uint256 newAvailability
    ) external onlyOrganizer(eventId) {
        Event storage event_ = events[eventId];
        require(categoryId < event_.categoryCount, "Invalid category ID");

        TicketCategory memory UpdatedCategory = TicketCategory(
            newName,
            newPrice,
            newAvailability
        );

        event_.ticketCategories[categoryId] = UpdatedCategory;

        emit categoryDetailsUpdated(eventId, categoryId, UpdatedCategory);
    }

    function refundAttendees(uint256 eventId) external onlyOrganizer(eventId) {
        Event storage event_ = events[eventId];
        require(event_.date < block.timestamp, "Event has not ended yet");

        for (uint256 i = 1; i <= _tokenIds.current(); i++) {
            if (ticketToEvent[i] == eventId && _exists(i)) {
                address ticketOwner = ownerOf(i);
                uint256 ticketPrice = event_
                    .ticketCategories[event_.ticketToCategory[i]]
                    .price;
                require(
                    token.transfer(ticketOwner, ticketPrice),
                    "Refund transfer failed"
                );

                _burn(i);

                emit attendeeRefunded(ticketOwner, ticketPrice);
            }
        }

        event_.isActive = false;
    }

    function blacklistUser(address user) external onlyOwner {
        blacklistedUsers[user] = true;
        emit userBlacklisted(user);
    }

    function transferCORE(address from, address to, uint256 _amount) internal {
        require(token.transferFrom(from, to, _amount), "CORE transfer failed");
    }

    function getActiveEvents() external view returns (uint256[] memory) {
        uint256 totalEvents = _eventIds.current();
        uint256 count = 0;

        for (uint256 i = 1; i <= totalEvents; i++) {
            if (events[i].isActive && !events[i].archived) {
                count++;
            }
        }

        uint256[] memory activeEventIds = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 1; i <= totalEvents; i++) {
            if (events[i].isActive && !events[i].archived) {
                activeEventIds[index] = i;
                index++;
            }
        }

        return activeEventIds;
    }
}
