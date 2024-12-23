// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./EchainManager.sol";
contract Ticketing is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    struct Event {
        string name;
        string description;
        string location;
        uint256 date;
        uint256 price;
        uint256 maxTickets;
        uint256 ticketsSold;
        address payable organizer;
        bool isActive;
    }

    Counters.Counter private _tokenIds;
    Counters.Counter private _eventIds;

    mapping(uint256 => Event) public events;
    mapping(uint256 => uint256) public ticketToEvent;
    mapping(uint256 => uint256) public resalePrices;
    mapping(uint256 => bool) public checkedInTickets;

    event EventCreated(uint256 eventId, string name, string location, uint256 date, uint256 price, uint256 maxTickets);
    event TicketMinted(uint256 ticketId, uint256 eventId, address owner);
    event EventClosed(uint256 eventId);
    event TicketResold(uint256 ticketId, address newOwner, uint256 resalePrice);
    event TicketCheckedIn(uint256 ticketId, uint256 eventId, address attendee);

    constructor() ERC721("EventTicket", "ETKT") {}

    modifier eventExists(uint256 eventId) {
        require(eventId > 0 && eventId <= _eventIds.current(), "Event does not exist");
        _;
    }

    modifier eventIsActive(uint256 eventId) {
        require(events[eventId].isActive, "Event is not active");
        _;
    }

    function createEvent(
        string memory name,
        string memory description,
        string memory location,
        uint256 date,
        uint256 price,
        uint256 maxTickets
    ) public {
        require(date > block.timestamp, "Event date must be in the future");
        require(maxTickets > 0, "Max tickets must be greater than zero");

        _eventIds.increment();
        uint256 newEventId = _eventIds.current();

        events[newEventId] = Event({
            name: name,
            description: description,
            location: location,
            date: date,
            price: price,
            maxTickets: maxTickets,
            ticketsSold: 0,
            organizer: payable(msg.sender),
            isActive: true
        });

        emit EventCreated(newEventId, name, location, date, price, maxTickets);
    }

}
