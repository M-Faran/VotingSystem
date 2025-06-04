# 🗳️ Decentralized Voting System

A fully on-chain decentralized voting system built with Solidity. This system enables transparent, tamper-proof elections where only whitelisted voters can participate. It supports multiple elections, each managed by its own admin.

---

## 📦 Features

- ✅ Create elections with custom candidates
- ✅ Set election start and end time using UNIX timestamps
- ✅ Whitelist specific voter addresses per election
- ✅ Cast votes during the voting period
- ✅ Prevent double voting and unauthorized access
- ✅ View all candidate details and vote counts
- ✅ Admin-only functions to manage elections and candidates

---

## 🧠 Smart Contract Overview

**Contract:** `VotingSystem.sol`

### 🏗 Structures

- `Candidate`: Stores `name` and `voteCount`
- `Election`: Stores admin address, timings, candidates, whitelist status, and voting status

### 🔐 Modifiers

- `onlyElectionAdmin`: Restricts functions to election admin
- `duringVoting`: Ensures function runs only during the active election time

---

## 🧪 How to Test (Using Remix)

1. **Open** [Remix IDE](https://remix.ethereum.org)
2. **Create** a new file: `VotingSystem.sol`, and paste the contract code.
3. **Compile** the contract using Solidity 0.8.x compiler.
4. **Deploy** the contract using "Remix VM (London)" environment.

### 🔧 Common Test Cases

#### ➕ Create an Election
- Use `createElection(["Alice", "Bob"], startTimestamp, endTimestamp)`
- Replace timestamps with valid [UNIX time](https://www.unixtimestamp.com/)

#### ✅ Whitelist Voters
- Call `whitelistVoters(electionId, ["0xYourAddressHere"])`

#### 🗳 Cast a Vote
- Call `vote(electionId, candidateId)` from a whitelisted address during the election period

#### 👀 View Results
- Use `getAllCandidates(electionId)` to see vote counts

---

## 🛠 Tech Stack

- **Solidity** - Smart contract language
- **Remix IDE** - For compiling, deploying, and testing
- **Ethers.js + HTML UI** - To integrate a frontend

---

## 🕒 Time Format

All election start and end times are stored as **UNIX timestamps** for compatibility with the blockchain. You can use online converters like [EpochConverter](https://www.epochconverter.com/) to generate readable times.

---

## ✅ License

This project is licensed under the MIT License.

