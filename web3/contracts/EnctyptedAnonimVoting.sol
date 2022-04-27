// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "OpenZeppelin/openzeppelin-contracts@4.6.0/contracts/utils/Strings.sol";

contract EncryptedAnonimVoting {

    enum VoterStatus {VOTED, NOT_VOTED}
    enum VotingStatus {TOO_EARLY, ACTIVE, FINISHED}

    bytes[] public votes;
    mapping(address => VoterStatus) voters_status;
    VotingStatus voting_status;
    string public name;
    address creator;

    string public public_key;

    // voted event
    event votedEvent();

    constructor (string memory _name, string memory _public_key, address[] memory _voters) {
        name = _name;
        public_key = _public_key;
        voting_status = VotingStatus.TOO_EARLY;

        for (uint i=0; i<_voters.length; i++) {
            voters_status[_voters[i]] = VoterStatus.NOT_VOTED;
        }

        creator = msg.sender;
    }

    function start_voting() public {
        require(creator == msg.sender);
        voting_status = VotingStatus.ACTIVE;
    }
    function finish_voting() public {
        require(creator == msg.sender);
        voting_status = VotingStatus.FINISHED;
    }

    function vote(bytes calldata _vote) public {
        require(voting_status == VotingStatus.ACTIVE);
        require(voters_status[msg.sender] == VoterStatus.NOT_VOTED, "You have already voted or not allowed to vote");

        votes.push(_vote);

        voters_status[msg.sender] = VoterStatus.VOTED;
        // trigger voted event
        emit votedEvent();
    }

    function tally_results() public view returns (bytes[] memory) {
        require(voting_status == VotingStatus.FINISHED);
        return votes;
    }
}