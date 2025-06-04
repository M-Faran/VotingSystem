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
        mapping(uint256 => Candidate) candidates; // Candidate ID to Candidate
        mapping(address => bool) hasVoted; // Voter address to vote status (true if voted)
        mapping(address => bool) isWhitelisted; // Whitelist per election
        bool exists; // Check if election exists
    }

    mapping(uint256 => Election) private elections; // electionId => Election
    uint256 public nextElectionId; // Incremental ID for each election

    event ElectionCreated(uint256 indexed electionId, address admin);
    event Voted(uint256 indexed electionId, uint256 candidateId, address voter);
    event VoterWhitelisted(uint256 indexed electionId, address voter);

    // Will be added to functions to restrict access to admin only
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

    // Admin can whitelist multiple voter addresses
    function whitelistVoters(uint256 electionId, address[] calldata voters) external onlyElectionAdmin(electionId) {
        Election storage e = elections[electionId];
        for (uint256 i = 0; i < voters.length; i++) {
            e.isWhitelisted[voters[i]] = true;
            emit VoterWhitelisted(electionId, voters[i]);
        }
    }

    // Cast a vote in a specific election
    function vote(uint256 electionId, uint256 candidateId) external duringVoting(electionId) {
        Election storage e = elections[electionId];
        require(e.isWhitelisted[msg.sender], "Not whitelisted to vote");
        require(!e.hasVoted[msg.sender], "Already voted");
        require(candidateId < e.candidateCount, "Invalid candidate");

        e.candidates[candidateId].voteCount++;
        e.hasVoted[msg.sender] = true;

        emit Voted(electionId, candidateId, msg.sender);
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

    // -------------- UI VIEW FUNCTIONS START HERE ------------------

    // Get candidate info (for display)
    function getCandidate(uint256 electionId, uint256 candidateId)
        external
        view
        returns (string memory name, uint256 voteCount)
    {
        Election storage e = elections[electionId];
        require(candidateId < e.candidateCount, "Invalid candidate");
        Candidate storage c = e.candidates[candidateId];
        return (c.name, c.voteCount);
    }

    // Get all candidates for a given election (array format)
    function getAllCandidates(uint256 electionId) external view returns (Candidate[] memory) {
        Election storage e = elections[electionId];
        Candidate[] memory candidateList = new Candidate[](e.candidateCount);
        for (uint256 i = 0; i < e.candidateCount; i++) {
            candidateList[i] = e.candidates[i];
        }
        return candidateList;
    }

    // Is election ongoing?
    function isVotingOngoing(uint256 electionId) public view returns (bool) {
        Election storage e = elections[electionId];
        return block.timestamp >= e.startTime && block.timestamp <= e.endTime;
    }

    // Has user voted?
    function hasUserVoted(uint256 electionId, address user) external view returns (bool) {
        return elections[electionId].hasVoted[user];
    }

    // Is user whitelisted?
    function isWhitelisted(uint256 electionId, address user) external view returns (bool) {
        return elections[electionId].isWhitelisted[user];
    }

    // Total number of candidates
    function getCandidateCount(uint256 electionId) external view returns (uint256) {
        return elections[electionId].candidateCount;
    }

    // Get election details
    function getElectionDetails(uint256 electionId)
        external
        view
        returns (address admin, uint256 startTime, uint256 endTime, bool votingLive)
    {
        Election storage e = elections[electionId];
        return (e.admin, e.startTime, e.endTime, isVotingOngoing(electionId));
    }

    // Check if election exists
    function doesElectionExist(uint256 electionId) external view returns (bool) {
        return elections[electionId].exists;
    }
}
