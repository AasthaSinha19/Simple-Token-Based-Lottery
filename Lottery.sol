// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract LotteryWithTiers {
    address public manager;

    // Enum representing lottery tiers
    enum LotteryTier { Daily, Weekly, Monthly }

    // Struct for each lottery tier
    struct Lottery {
        uint256 ticketPrice;
        address[] players;
        bool isActive;
    }

    // Mapping of tiers to lottery details
    mapping(LotteryTier => Lottery) public lotteries;

    event TicketPurchased(address indexed player, LotteryTier tier, uint256 amount);
    event WinnerSelected(address indexed winner, LotteryTier tier, uint256 prizeAmount);

    constructor() {
        manager = msg.sender;

        // Initialize lotteries with different ticket prices
        lotteries[LotteryTier.Daily].ticketPrice = 0.01 ether;
        lotteries[LotteryTier.Daily].isActive = true;

        lotteries[LotteryTier.Weekly].ticketPrice = 0.05 ether;
        lotteries[LotteryTier.Weekly].isActive = true;

        lotteries[LotteryTier.Monthly].ticketPrice = 0.1 ether;
        lotteries[LotteryTier.Monthly].isActive = true;
    }

    // Function to buy a ticket for a specific lottery tier
    function buyTicket(LotteryTier tier) public payable {
        require(lotteries[tier].isActive, "This lottery tier is not active");
        require(msg.value == lotteries[tier].ticketPrice, "Incorrect ticket price");

        lotteries[tier].players.push(msg.sender);
        emit TicketPurchased(msg.sender, tier, msg.value);
    }

    // Function to select a winner for a specific lottery tier
    function selectWinner(LotteryTier tier) public {
        require(msg.sender == manager, "Only manager can select winner");
        require(lotteries[tier].players.length > 0, "No players in this lottery tier");

        uint256 winnerIndex = random(tier) % lotteries[tier].players.length;
        address winner = lotteries[tier].players[winnerIndex];

        uint256 prizeAmount = address(this).balance;
        payable(winner).transfer(prizeAmount);

        emit WinnerSelected(winner, tier, prizeAmount);

        // Reset the player list for the next round
        delete lotteries[tier].players;
    }

    // Private function for pseudo-random winner selection
    function random(LotteryTier tier) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, lotteries[tier].players.length)));
    }

    // Get players in a specific lottery tier
    function getPlayers(LotteryTier tier) public view returns (address[] memory) {
        return lotteries[tier].players;
    }

    // Get contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

