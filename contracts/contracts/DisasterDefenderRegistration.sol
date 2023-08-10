// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisasterDefenderRegistration {

    enum UserType { Volunteer, AidRecipient }

    struct Volunteer {
        string name;
        string email;
        string specialty;
        string region;
    }

    struct AidRecipient {
        string name;
        string email;
        string location;
        string aidType;
        uint256 numPeople;
        string contactNum;
    }

    // Arrays to store all volunteers and aid recipients
    Volunteer[] public volunteers;
    AidRecipient[] public aidRecipients;

    // Mapping of region to volunteer and aid recipient indices
    mapping(string => uint256[]) public volunteerIndicesByRegion;
    mapping(string => uint256[]) public aidRecipientIndicesByRegion;

    function registerVolunteer(
        string memory _name,
        string memory _email,
        string memory _specialty,
        string memory _region
    ) public {
        volunteers.push(Volunteer(_name, _email, _specialty, _region));
        volunteerIndicesByRegion[_region].push(volunteers.length - 1);
    }

    function registerAidRecipient(
        string memory _name,
        string memory _email,
        string memory _location,
        string memory _aidType,
        uint256 _numPeople,       
        string memory _contactNum        
    ) public {
        aidRecipients.push(AidRecipient(_name, _email, _location, _aidType, _numPeople, _contactNum));
        aidRecipientIndicesByRegion[_location].push(aidRecipients.length - 1);
    }

    // Functions to retrieve volunteers and aid recipients based on region
    function getVolunteersByRegion(string memory _region) public view returns (Volunteer[] memory) {
        uint256[] memory indices = volunteerIndicesByRegion[_region];
        Volunteer[] memory regionVolunteers = new Volunteer[](indices.length);
        
        for (uint256 i = 0; i < indices.length; i++) {
            regionVolunteers[i] = volunteers[indices[i]];
        }
        
        return regionVolunteers;
    }

    function getAidRecipientsByRegion(string memory _region) public view returns (AidRecipient[] memory) {
        uint256[] memory indices = aidRecipientIndicesByRegion[_region];
        AidRecipient[] memory regionAidRecipients = new AidRecipient[](indices.length);
        
        for (uint256 i = 0; i < indices.length; i++) {
            regionAidRecipients[i] = aidRecipients[indices[i]];
        }
        
        return regionAidRecipients;
    }
}
