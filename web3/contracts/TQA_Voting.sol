pragma solidity ^0.8.0;

contract TQA_Voting {
    uint private MIN_VOTE = 1;
    uint private MAX_VOTE = 10;

    // Question types for СОП
    //    enum QuestionType{FUTURE_CAREER, PERSONAL_DEVELOPMENT, NEW_KNOWLEDGE, DIFFICULTY}
    enum QuestionType{FUTURE_CAREER, DIFFICULTY}

    struct Vote {
        uint future_career_mark;
        uint difficulty_mark;
        string comment;
    }

    Vote[] public votes;
    mapping(address => bool) voters;
    string public name;

    // voted event
    event votedEvent();

    constructor (string memory _name) public {
        name = _name;
    }


    function vote(Vote calldata _vote) public {
        // require that they haven't voted before
        require(!voters[msg.sender], "You have already voted");

        require(_vote.future_career_mark >= MIN_VOTE && _vote.future_career_mark <= MAX_VOTE);
        require(_vote.difficulty_mark >= MIN_VOTE && _vote.difficulty_mark <= MAX_VOTE);
        require(bytes(_vote.comment).length > 0);

        votes.push(_vote);
        //
        //        // require a valid candidate
        //        require(_candidateId > 0 && _candidateId <= candidatesCount);
        //
        //        // record that voter has voted
        //        voters[msg.sender] = true;
        //
        //        // update candidate vote Count
        //        candidates[_candidateId].voteCount ++;

        // trigger voted event
        emit votedEvent();
    }
}