// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Vote {
    // ── Variables d'état ──────────────────────────────────────────────────

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public owner;
    Candidate[] private candidates;
    mapping(address => uint256) public lastVoteTime;
    uint256 public constant COOLDOWN = 3 minutes;

    // ── Events ───────────────────────────────────────────────────────────

    event Voted(address indexed voter, uint256 candidateIndex);

    // ── Constructor ──────────────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
        candidates.push(Candidate("Leon Blum", 0));
        candidates.push(Candidate("Jacques Chirac", 0));
        candidates.push(Candidate("Francois Mitterrand", 0));
    }

    // ── Fonctions view (lecture gratuite) ────────────────────────────────

    function getCandidatesCount() external view returns (uint256) {
        return candidates.length;
    }

    function getCandidate(uint256 index) external view returns (string memory name, uint256 voteCount) {
        require(index < candidates.length, "Index invalide");
        Candidate storage c = candidates[index];
        return (c.name, c.voteCount);
    }

    function getTimeUntilNextVote(address voter) external view returns (uint256) {
        uint256 lastTime = lastVoteTime[voter];
        if (lastTime == 0) return 0;
        uint256 nextAllowed = lastTime + COOLDOWN;
        if (block.timestamp >= nextAllowed) return 0;
        return nextAllowed - block.timestamp;
    }

    // ── Fonction d'écriture (coûte du gas) ───────────────────────────────

    function vote(uint256 candidateIndex) external {
        require(candidateIndex < candidates.length, "Candidat inexistant");
        require(
            lastVoteTime[msg.sender] == 0 ||
            block.timestamp >= lastVoteTime[msg.sender] + COOLDOWN,
            "Cooldown actif, attendez avant de revoter"
        );

        candidates[candidateIndex].voteCount += 1;
        lastVoteTime[msg.sender] = block.timestamp;

        emit Voted(msg.sender, candidateIndex);
    }
}
