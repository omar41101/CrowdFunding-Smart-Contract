// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CrowdFunding {
    using SafeMath for uint256; // Use SafeMath for safe arithmetic operations

    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 amountCollected;
        string image;
        bool completed; // New field to track if the campaign has been completed
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    // Create a new campaign (owner is the creator of the campaign)
    function createCampaign(
        address _owner,
        string calldata _title,
        string calldata _description,
        uint256 _target,
        string calldata _image
    ) external returns (uint256) {
        require(_target > 0, "Target must be greater than 0");
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_owner != address(0), "Invalid owner address");

        Campaign storage campaign = campaigns[numberOfCampaigns];
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.amountCollected = 0;
        campaign.image = _image;
        campaign.completed = false; // Initialize the campaign as incomplete

        numberOfCampaigns = numberOfCampaigns.add(1);

        return numberOfCampaigns.sub(1);
    }

    // Donate to a specific campaign with checks-effects-interactions pattern
    function donateToCampaign(uint256 _id) external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        Campaign storage campaign = campaigns[_id];
        require(campaign.owner != address(0), "Campaign does not exist");
        require(!campaign.completed, "Campaign already completed"); // Ensure the campaign isn't already completed

        // Store initial amountCollected in memory
        uint256 initialAmountCollected = campaign.amountCollected;

        // Effects
        campaign.donators.push(msg.sender);
        campaign.donations.push(msg.value);

        // Use SafeMath for addition to protect from overflow
        campaign.amountCollected = campaign.amountCollected.add(msg.value);

        // Check if the target is met or exceeded
        if (campaign.amountCollected >= campaign.target) {
            campaign.completed = true; // Mark the campaign as completed
        }

        // Interactions: Transfer all donated Ether to the campaign owner
        (bool sent, ) = payable(campaign.owner).call{value: msg.value}("");
        require(sent, "Failed to send Ether to campaign owner");

        // Ensure amountCollected is properly updated
        assert(campaign.amountCollected == initialAmountCollected.add(msg.value));
    }

    // Get the list of donators and their donations for a specific campaign
    function getDonators(uint256 _id) external view returns (address[] memory, uint256[] memory) {
        Campaign storage campaign = campaigns[_id];
        return (campaign.donators, campaign.donations);
    }

    // Get all campaigns
    function getCampaigns() external view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    // Update an existing campaign (only the owner can update)
    function updateCampaign(
        uint256 _id,
        string calldata _title,
        string calldata _description,
        uint256 _target,
        string calldata _image
    ) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "Only the campaign owner can update");
        require(_target > 0, "Target must be greater than 0");
        require(!campaign.completed, "Cannot update a completed campaign");

        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.image = _image;
    }

    // Delete a campaign (only the owner can delete)
    function deleteCampaign(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "Only the campaign owner can delete");
        require(campaign.amountCollected == 0, "Cannot delete a campaign with funds");

        delete campaigns[_id];
    }
}
