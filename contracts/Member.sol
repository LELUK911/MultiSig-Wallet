// SPDX-License-Identifier: Leluk

pragma solidity 0.8.7;

contract Member {
    // Governan's members
    address[] internal members;
    //Governans can vote for one member for at time
    address internal pendigMembers;
    // voteRequireNewMember using during votation, in other time  'voteRequireNewMember == 0'
    uint256 internal voteRequireNewMember;
    // voteMember check if member already vote
    mapping(address => mapping(address => bool)) internal voteMember;
    // status member in case votation Ban
    enum MemberFlag {
        BANVOTE,
        BAN
    }
    // black list users
    mapping(address => mapping(MemberFlag => uint256)) internal blackList;
    // voteMember check if member already vote for ban
    mapping(address => mapping(address => bool)) internal voteBanMember;

    constructor(address[] memory _members) {
        require(_members.length >= 5, "Set min 5 member");
        for (uint256 i; i < _members.length; i++) {
            require(_members[i] != address(0), "Set assett correct in array");
        }
        members = _members;
    }

    //========= MODIFIER =========//
    modifier MemberExist(address _to) {
        require(_memberExist(_to), "Not you are actual member");
        _;
    }

    //========= VIEW FUNCTION =========//

    function _memberExist(address _member)
        internal
        view
        returns (bool response)
    {
        for (uint256 i; i < members.length; i++) {
            if (members[i] == _member) {
                return response = true;
            }
        }
        response = false;
    }

    function _memberBanActual(address _member)
        internal
        view
        returns (bool response)
    {
        if (blackList[_member][MemberFlag.BAN] == 0) {
            response = true;
        }
    }

    //========= INTERNAL FUNCTION =========//
    event newProposalMember(address indexed _newMember);

    function _proposalnewMember(address _to, address _member)
        internal
        MemberExist(_to)
    {
        require(_member != address(0), "sett correct Address");
        require(
            pendigMembers == address(0),
            "Votation for new member already in execution"
        );
        require(!_memberExist(_member), "address already present");
        require(!_memberBanActual(_member), "member is ban");
        voteRequireNewMember = (members.length / 2) + 1;
        pendigMembers = _member;
        emit newProposalMember(_member);
    }

    event executeVote(
        address indexed _newMember,
        address indexed member,
        bool _vote
    );

    function _vote(address _to, bool vote) internal MemberExist(_to) {
        require(!voteMember[_to][pendigMembers], "member already take vote");
        require(
            pendigMembers != address(0),
            "Votation for new member not in execution"
        );
        voteMember[_to][pendigMembers] = true;
        emit executeVote(pendigMembers, _to, vote);
        if (vote == true) {
            voteRequireNewMember -= 1;
            if (voteRequireNewMember == 0) {
                _setMember();
            }
        }
    }

    event addNewMember(address indexed _newMember);

    function _setMember() internal {
        members.push(pendigMembers);
        emit addNewMember(pendigMembers);
    }

    event newBanProposal(address indexed newBanMember);

    function _proposalBanMember(address _to, address _banMember)
        internal
        MemberExist(_to)
    {
        require(_memberExist(_banMember), "Member not Exist");
        require(
            blackList[_banMember][MemberFlag.BANVOTE] == 0,
            "already in list"
        );
        blackList[_banMember][MemberFlag.BANVOTE] = 0;
        emit newBanProposal(_banMember);
    }

    event executeVoteBan(address indexed memberBan, address indexed member);

    function _voteForBan(address _to, address _banMember)
        internal
        MemberExist(_to)
    {
        require(
            blackList[_banMember][MemberFlag.BANVOTE] >= 0,
            "Member not signal"
        );
        require(!voteBanMember[_to][_banMember], "member already take vote");
        voteBanMember[_to][_banMember] = true;
        blackList[_banMember][MemberFlag.BANVOTE] += 1;
        emit executeVoteBan(_banMember, _to);
        if (
            blackList[_banMember][MemberFlag.BANVOTE] ==
            (members.length / 2) + 1
        ) {
            _ban(_banMember);
        }
    }

    event ban(address indexed userBan);

    function _ban(address _banMember) internal {
        blackList[_banMember][MemberFlag.BAN] = 0;
        for (uint256 i; i < members.length; i++) {
            if (members[i] == _banMember) {
                members[i] = members[members.length - 1];
                members.pop();
                emit ban(_banMember);
            }
        }
    }
}
