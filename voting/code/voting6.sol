// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {

    struct Proposal {
        address target;
        bytes data;
        uint256 yesCount;
        uint256 noCount;
        bool executed; 
    }

    Proposal[] public proposals;

    mapping(uint256 => mapping(address => bool)) public votes;

    mapping(uint256 => mapping(address => bool)) public hasVoted;

    mapping(address => bool) public allowedMembers;

    event ProposalCreated(uint proposalId);

    event VoteCast(uint proposalId, address voter);

  
    constructor(address[] memory initialMembers) {

        allowedMembers[msg.sender] = true;

        for (uint i = 0; i < initialMembers.length; i++) {
            allowedMembers[initialMembers[i]] = true;
        }
    }

    modifier onlyAllowedMembers() {
        require(allowedMembers[msg.sender], "Caller is not an allowed member");
        _;
    }

    function newProposal(address _target, bytes calldata _data) external onlyAllowedMembers {
        Proposal memory proposal = Proposal({
            target: _target,
            data: _data,
            yesCount: 0,
            noCount: 0,
            executed: false
        });
        proposals.push(proposal);
        emit ProposalCreated(proposals.length - 1);
    }
    function castVote(uint proposalId, bool support) external onlyAllowedMembers {
        require(proposalId < proposals.length, "Invalid proposalId");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal has already been executed");
        if (hasVoted[proposalId][msg.sender]) {
            bool previousVote = votes[proposalId][msg.sender];
            if (previousVote != support) {
                if (previousVote) {
                    proposal.yesCount--;
                } else {
                    proposal.noCount--;
                }

                if (support) {
                    proposal.yesCount++;
                } else {
                    proposal.noCount++;
                }

 
                votes[proposalId][msg.sender] = support;
            }
        } else {
            if (support) {
                proposal.yesCount++;
            } else {
                proposal.noCount++;
            }

            votes[proposalId][msg.sender] = support;
            hasVoted[proposalId][msg.sender] = true;
        }

        emit VoteCast(proposalId, msg.sender);
        if (proposal.yesCount >= 10 && !proposal.executed) {
            proposal.executed = true;
            (bool success, ) = proposal.target.call(proposal.data);
            require(success, "Proposal execution failed");
        }
    }
}