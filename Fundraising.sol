pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
contract Fundraising{
    uint goal;
    uint public deadline;
    uint public minimumContribution;
    address public admin;
    uint public noOfContributors;
    mapping(address => uint) contributors;
    uint public raisedAmount = 0;

    event contributeEvent(address sender, uint value);
    event createRequestEvent(string description, address _address, uint value);
    event makePaymentEvent(address recipient, uint value);

    //spending request
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    uint numRequests;
    mapping (uint => Request) requests;

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        admin = msg.sender;
        minimumContribution = 10;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    function contribute() public payable{
        require(msg.value > minimumContribution);
        require(block.timestamp < deadline);
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount +=msg.value;
        emit contributeEvent(msg.sender, msg.value);
    }
    //refund if goal is not met within deadline
    function getRefund() public{
        require(block.timestamp > deadline);
        require(raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);
        contributors[msg.sender] = 0;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    //admin creates spending request
    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{
        Request storage newRequest = requests[numRequests++];
        newRequest.description =  _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        emit createRequestEvent(_description, _recipient, _value);
    }

    //contributors vote for spending request
    function voteRequest(uint index) public{
        Request storage request = requests[index];

        require(contributors[msg.sender]>0);
        require(request.voters[msg.sender] == false);

        request.voters[msg.sender] = true;
        request.noOfVoters++;
    }
    //owner sends funds if voted 'yes' 
    function makePayment(uint index) public onlyAdmin{
        Request storage request = requests[index];
        require(request.completed == false);
        require(request.noOfVoters > noOfContributors/2); // more than 50% voters
        require(raisedAmount>=goal);
        request.recipient.transfer(request.value);
        request.completed = true;
        emit makePaymentEvent(request.recipient,  request.value );

    }

}