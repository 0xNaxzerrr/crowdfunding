// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FundraisingCampaign.sol";

contract FundraisingFactory {
    address public platformToken;
    address public owner;

    struct CampaignInfo {
        FundraisingCampaign campaign;
        bool accepted;
        bool rejected;
    }

    mapping(address => CampaignInfo[]) public campaigns;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _platformToken) {
        platformToken = _platformToken;
        owner = msg.sender;
    }

    function submitCampaign(
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _startDate,
        uint256 _endDate
    ) external {
        FundraisingCampaign newCampaign = new FundraisingCampaign(
            platformToken,
            msg.sender,
            _minAmount,
            _maxAmount,
            _startDate,
            _endDate
        );
        campaigns[msg.sender].push(CampaignInfo(newCampaign, false, false));
    }

    function acceptCampaign(
        address _applicant,
        uint256 _index
    ) external onlyOwner {
        require(!campaigns[_applicant][_index].accepted, "Already accepted");
        campaigns[_applicant][_index].accepted = true;
    }

    function rejectCampaign(
        address _applicant,
        uint256 _index
    ) external onlyOwner {
        require(!campaigns[_applicant][_index].rejected, "Already rejected");
        campaigns[_applicant][_index].rejected = true;
    }

    function getCampaignStatus(
        address _applicant,
        uint256 _index
    ) external view returns (bool accepted, bool rejected) {
        CampaignInfo storage info = campaigns[_applicant][_index];
        return (info.accepted, info.rejected);
    }
}
