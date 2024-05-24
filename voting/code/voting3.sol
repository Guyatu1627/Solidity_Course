// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint256 yesCount;
        uint256 noCount;
    }
    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public votes;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    function newProposal(address _target, bytes calldata _data) external {
        Proposal memory proposal = Proposal({
            target: _target,
            data: _data,
            yesCount: 0,
            noCount: 0
        });
        proposals.push(proposal);
    }
    function castVote(uint proposalId, bool support) external {
        require(proposalId < proposals.length, "Invalid proposalId");
        Proposal storage proposal = proposals[proposalId];

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
    }
}
