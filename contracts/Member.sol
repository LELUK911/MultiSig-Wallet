// SPDX-License-Identifier: Leluk

pragma solidity 0.8.7;

contract Member {
    address[] internal guardians;
    address[] internal members;
    address internal pendigMembers;
    uint256 internal voteRequireNewMember;
    mapping(address => mapping(address => bool)) internal voteMember;

    enum MemberFlag {
        BANVOTE,
        BAN
    }
    mapping(address => mapping(MemberFlag => uint256)) internal blackList;
    mapping(address => mapping(address => bool)) internal banMember;

    constructor(address[] memory _guardian) {
        guardians = _guardian;
    }

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
        voteRequireNewMember = (members.length / 2) + 1;
        pendigMembers = _member;
    }

    function _vote(address _to, bool vote) internal MemberExist(_to) {
        require(!voteMember[_to][pendigMembers], "member already take vote");
        require(
            pendigMembers != address(0),
            "Votation for new member not in execution"
        );
        voteMember[_to][pendigMembers] = true;
        if (vote == true) {
            voteRequireNewMember -= 1;
            if (voteRequireNewMember == 0) {
                _setMember();
            }
        }
    }

    function _setMember() internal {
        address newMember = pendigMembers;
        pendigMembers = address(0);
        members.push(newMember);
    }

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
    }

    //voteMember[_to][pendigMembers]

    function _voteForBan(address _to, address _banMember)
        internal
        MemberExist(_to)
    {
        require(
            blackList[_banMember][MemberFlag.BANVOTE] >= 0,
            "Member not signal"
        );
        require(!banMember[_to][_banMember], "member already take vote");
        banMember[_to][_banMember] = true;
        blackList[_banMember][MemberFlag.BANVOTE] += 1;
        if (
            blackList[_banMember][MemberFlag.BANVOTE] ==
            (members.length / 2) + 1
        ) {
            _ban(_banMember);
        }
    }

    function _ban(address _banMember) internal {}

    modifier MemberExist(address _to) {
        require(_memberExist(_to), "Not you are actual member");
        _;
    }
}
