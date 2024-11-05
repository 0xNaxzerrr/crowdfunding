// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CustomSwap {
    address public platformToken;
    address public owner;
    uint256 public conversionRate;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _platformToken, uint256 _conversionRate) {
        platformToken = _platformToken;
        owner = msg.sender;
        conversionRate = _conversionRate;
    }

    function updateConversionRate(uint256 _rate) external onlyOwner {
        conversionRate = _rate;
    }

    function swap(address _fromToken, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        uint256 platformTokenAmount = (_amount * conversionRate) / 100;
        IERC20(_fromToken).transferFrom(msg.sender, address(this), _amount);
        IERC20(platformToken).transfer(msg.sender, platformTokenAmount);
    }
}
