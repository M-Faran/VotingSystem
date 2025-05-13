// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public admin;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public candidatesCount;

    mapping(uint256 => Candidate) public candidates; //Candidate ID to Candidate
    mapping(address => bool) public hasVoted; //Voter address to vote status (true if voted)

    modifier onlyAdmin() {
        //Will be added to functions to restrict access to admin only
        require(msg.sender == admin, "Only admin can call this.");
        _;
    }

    modifier duringVoting() {
        //Will be added to functions to make sure votes related activity is done only during voting time
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting not active.");
        _;
    }

    constructor(string[] memory candidateNames, uint256 _startTime, uint256 _endTime) {
        require(_endTime > _startTime, "Voting time ended");

        admin = msg.sender;
        startTime = _startTime;
        endTime = _endTime;

        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates[i] = Candidate(candidateNames[i], 0);
        }

        candidatesCount = candidateNames.length;
    }

    function addCandidate(string memory name) public onlyAdmin {
        candidates[candidatesCount] = Candidate(name, 0);
        candidatesCount++;
    }

    function vote(uint256 candidateId) public duringVoting {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(candidateId < candidatesCount, "Invalid candidate ID.");

        candidates[candidateId].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getCandidate(uint256 id) public view returns (string memory name, uint256 votes) {
        Candidate memory c = candidates[id];
        return (c.name, c.voteCount);
    }
}
