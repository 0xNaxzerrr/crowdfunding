// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract FundraisingCampaign is ReentrancyGuard {
    address public owner;
    address public platformToken;
    address public applicant;
    uint256 public tokenTargetMinAmount;
    uint256 public tokenTargetMaxAmount;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public totalFunds;
    bool public isClaimed;

    mapping(address => uint256) public contributions;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyApplicant() {
        require(msg.sender == applicant, "Not the applicant");
        _;
    }

    constructor(
        address _platformToken,
        address _applicant,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _startDate,
        uint256 _endDate
    ) {
        owner = msg.sender;
        platformToken = _platformToken;
        applicant = _applicant;
        tokenTargetMinAmount = _minAmount;
        tokenTargetMaxAmount = _maxAmount;
        startDate = _startDate;
        endDate = _endDate;
    }

    function contribute(address _token, uint256 _amount) external {
        require(block.timestamp >= startDate, "Campaign has not started");
        require(block.timestamp <= endDate, "Campaign has ended");
        require(
            totalFunds + _amount <= tokenTargetMaxAmount,
            "Max target reached"
        );

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        contributions[msg.sender] += _amount;
        totalFunds += _amount;
    }

    function claimFunds() external onlyApplicant nonReentrant {
        require(
            block.timestamp > endDate || totalFunds >= tokenTargetMaxAmount,
            "Campaign ongoing"
        );
        require(totalFunds >= tokenTargetMinAmount, "Target not reached");
        require(!isClaimed, "Already claimed");

        IERC20(platformToken).transfer(applicant, totalFunds);
        isClaimed = true;
    }

    function refund() external nonReentrant {
        require(totalFunds < tokenTargetMinAmount, "Target reached");
        uint256 contributed = contributions[msg.sender];
        require(contributed > 0, "No contributions");

        contributions[msg.sender] = 0;
        totalFunds -= contributed;
        IERC20(platformToken).transfer(msg.sender, contributed);
    }
}
