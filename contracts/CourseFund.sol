// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICourseToken {
    function mint(address to, uint256 amount) external;
}

contract CourseFund {
    struct Campaign {
        address creator;
        string title;
        uint256 goal;
        uint256 deadline;
        uint256 totalFunded;
        bool finalized;
        bool success;
    }

    ICourseToken public rewardToken;
    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    // events to front 
    event CampaignCreated(uint256 id, string title, uint256 goal, uint256 deadline);
    event ContributionMade(uint256 campaignId, address contributor, uint256 amount);
    event CampaignFinalized(uint256 id, bool success);

    constructor(address _tokenAddress) {
        rewardToken = ICourseToken(_tokenAddress);
    }

    function createCampaign(string memory _title, uint256 _goal, uint256 _durationDays) public {
        require(_goal > 0, "Goal must be > 0");
        campaignCount++;
        
        uint256 deadline = block.timestamp + (_durationDays * 1 days);
        
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            title: _title,
            goal: _goal,
            deadline: deadline,
            totalFunded: 0,
            finalized: false,
            success: false
        });

        emit CampaignCreated(campaignCount, _title, _goal, deadline);
    }

    function contribute(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign is over");
        require(msg.value > 0, "Send some ETH");

        campaign.totalFunded += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        rewardToken.mint(msg.sender, msg.value * 100);

        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    function finalize(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Not reached deadline");
        require(!campaign.finalized, "Already finalized");

        campaign.finalized = true;
        if (campaign.totalFunded >= campaign.goal) {
            campaign.success = true;
            (bool success, ) = payable(campaign.creator).call{value: campaign.totalFunded}("");
            require(success, "Transfer failed");
        }
        
        emit CampaignFinalized(_campaignId, campaign.success);
    }
}