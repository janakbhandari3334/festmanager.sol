// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Festmanager {
    address public admin;
    uint public eventCount = 0;

    struct EventStruct {
        string title;
        string date;
        uint capacity;
        uint registeredCount;
        uint voteCount;
        bool active;
    }

    mapping(uint => EventStruct) public events;
    mapping(uint => mapping(address => bool)) public registered;
    mapping(uint => mapping(address => bool)) public voted;
    mapping(uint => mapping(address => bool)) public present;

    event EventCreated(uint indexed eventId, string title, string date, uint capacity);
    event Registered(uint eventId, address attendance);
    event Voted(uint eventId, address voter);
    event MarkedPresent(uint eventId, address attendee);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createEvent(string memory _title, string memory _date, uint _capacity) public onlyAdmin {
        events[eventCount] = EventStruct(_title, _date, _capacity, 0, 0, true);
        emit EventCreated(eventCount, _title, _date, _capacity);
        eventCount++;
    }

    function registerForEvent(uint _eventId) public {
        require(events[_eventId].active, "Event inactive");
        require(!registered[_eventId][msg.sender], "Already registered");
        require(events[_eventId].registeredCount < events[_eventId].capacity, "Event full");

        registered[_eventId][msg.sender] = true;
        events[_eventId].registeredCount++;
        emit Registered(_eventId, msg.sender);
    }

    function vote(uint _eventId) public {
        require(events[_eventId].active, "Event inactive");
        require(registered[_eventId][msg.sender], "Not registered");
        require(!voted[_eventId][msg.sender], "Already voted");

        voted[_eventId][msg.sender] = true;
        events[_eventId].voteCount++;
        emit Voted(_eventId, msg.sender);
    }

    function markPresent(uint _eventId, address _attendee) public onlyAdmin {
        require(registered[_eventId][_attendee], "Not registered");
        require(!present[_eventId][_attendee], "Already marked present");

        present[_eventId][_attendee] = true;
        emit MarkedPresent(_eventId, _attendee);
    }
    function getEvent(uint _eventId) public view returns (string memory, string memory, uint, uint, uint, bool) {
        EventStruct memory e = events[_eventId];
        return (e.title, e.date, e.capacity, e.registeredCount, e.voteCount, e.active);
    }
}
