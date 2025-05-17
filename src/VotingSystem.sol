// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Election {
        address admin;
        uint256 startTime;
        uint256 endTime;
        uint256 candidateCount;
        mapping(uint256 => Candidate) candidates; //Candidate ID to Candidate
        mapping(address => bool) hasVoted; //Voter address to vote status (true if voted)
        bool exists; // Check if election exists
    }

    mapping(uint256 => Election) private elections; // electionId => Election
    uint256 public nextElectionId; // Incremental ID for each election

    event ElectionCreated(uint256 indexed electionId, address admin);
    event Voted(uint256 indexed electionId, uint256 candidateId, address voter);

    //Will be added to functions to restrict access to admin only
    modifier onlyElectionAdmin(uint256 electionId) {
        require(elections[electionId].exists, "No such election");
        require(msg.sender == elections[electionId].admin, "Not admin");
        _;
    }

    //Will be added to functions to make sure votes related activity is done only during voting time
    modifier duringVoting(uint256 electionId) {
        Election storage e = elections[electionId];
        require(block.timestamp >= e.startTime && block.timestamp <= e.endTime, "Voting closed");
        _;
    }

    // Create a new election
    function createElection(string[] memory candidateNames, uint256 _startTime, uint256 _endTime)
        external
        returns (uint256 electionId)
    {
        require(_endTime > _startTime, "Wrong time window");

        electionId = nextElectionId++;
        Election storage e = elections[electionId];
        e.admin = msg.sender;
        e.startTime = _startTime;
        e.endTime = _endTime;
        e.exists = true;

        for (uint256 i = 0; i < candidateNames.length; i++) {
            e.candidates[i] = Candidate(candidateNames[i], 0);
        }
        e.candidateCount = candidateNames.length;

        emit ElectionCreated(electionId, msg.sender);
    }

    // Cast a vote in a specific election
    function vote(uint256 electionId, uint256 candidateId) external duringVoting(electionId) {
        Election storage e = elections[electionId];
        require(!e.hasVoted[msg.sender], "Already voted");
        require(candidateId < e.candidateCount, "Invalid candidate");

        e.candidates[candidateId].voteCount++;
        e.hasVoted[msg.sender] = true;

        emit Voted(electionId, candidateId, msg.sender);
    }

    // Read a candidate’s info
    function getCandidate(uint256 electionId, uint256 candidateId)
        external
        view
        returns (string memory name, uint256 votes)
    {
        Election storage e = elections[electionId];
        Candidate storage c = e.candidates[candidateId];
        return (c.name, c.voteCount);
    }

    // Add a candidate to an existing election
    function addCandidate(uint256 electionId, string memory name) external onlyElectionAdmin(electionId) {
        Election storage e = elections[electionId];
        // Check for duplicate candidate name
        for (uint256 i = 0; i < e.candidateCount; i++) {
            if (keccak256(bytes(e.candidates[i].name)) == keccak256(bytes(name))) {
                revert("Candidate with this name already exists");
            }
        }
        e.candidates[e.candidateCount++] = Candidate(name, 0);
    }
}
