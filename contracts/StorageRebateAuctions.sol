// SPDX-License-Identifier: Apache-2.0 and MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

contract StorageRebateAuctions is ReentrancyGuard {
    struct Auction {
        uint64 dealId;
        address payable clientFEVMaddress;
        address payable winningProviderFEVMaddress;
        uint64 winningProvider;
        uint256 clientSecurityDeposit;
        uint256 minRebate;
        uint256 rebate;
        uint256 minRebateIncrementRatio; // 18 decimals; 1.05 * 10**18 would mean 5%
        uint256 closingTime;
        uint256 realizationDeadline;
    }
    Auction[] public auctions;

    function numAuctions() external view returns (uint256) { return auctions.length; }

    function exists(uint64 dealId) public /*view*/ returns (bool) {
        console.log("Checking deal exists");
        MarketTypes.GetDealVerifiedReturn memory v = MarketAPI.getDealVerified(dealId);
        console.log("Deal exists: %d", v.verified);
        return v.verified;
    }

    function isCorrectDealProvider(uint256 auctionId) internal /*view*/ returns (bool) {
        MarketTypes.GetDealProviderReturn memory p = MarketAPI.getDealProvider(auctions[auctionId].dealId);
        return p.provider == auctions[auctionId].winningProvider;
    }

    function isDealOpen(uint64 dealId) public /*view*/ returns (bool) {
        require(exists(dealId), "Deal not verified or does not exist");
        MarketTypes.GetDealProviderReturn memory p = MarketAPI.getDealProvider(dealId);
        console.log("Deal provider: %d", p.provider);
        return p.provider != 0;
    }

//     function dealCient(uint64 dealId) internal view returns (address client) {
// !!! not implemented
//     }

    function isValid(uint256 auctionId) external view returns (bool) {
        return auctionId < auctions.length && auctions[auctionId].clientSecurityDeposit != 0;
    }

    function startNew(
        uint64 _dealId,
        uint256 _minRebate,
        uint256 _minRebateIncrementRatio,
        uint256 _closingTime,
        uint256 _realizationDeadline
    ) external payable returns (uint256 auctionId) {
        // require(dealClient(dealId) == msg.sender, "Not deal owner");
        require(isDealOpen(_dealId), "Deal not available");
        require(_closingTime > block.timestamp, "Bad closing time");
        require(_realizationDeadline > _closingTime, "Bad realization deadline");
        require(msg.value > 0, "No security deposit");
        auctionId = auctions.length;
        auctions.push();
        auctions[auctionId].dealId = _dealId;
        auctions[auctionId].clientFEVMaddress = payable(msg.sender);
        // auctions[auctionId].winningProviderFEVMaddress = address(0);
        // auctions[auctionId].winningProvider = 0;
        auctions[auctionId].clientSecurityDeposit = msg.value;
        auctions[auctionId].minRebate = _minRebate;
        // auctions[auctionId].rebate = 0; 
        auctions[auctionId].minRebateIncrementRatio = _minRebateIncrementRatio;
        auctions[auctionId].closingTime = _closingTime;
        auctions[auctionId].realizationDeadline = _realizationDeadline;
    }

    function bid(uint256 auctionId, uint64 provider) external payable nonReentrant {
        require(block.timestamp <= auctions[auctionId].closingTime, "Auction ended");
        require(isDealOpen(auctions[auctionId].dealId), "Deal not available");
        require(auctions[auctionId].clientSecurityDeposit > 0, "No security deposit");
        require(msg.value >= auctions[auctionId].minRebate, "Min rebate");
        require(auctions[auctionId].rebate == 0 || msg.value >= auctions[auctionId].rebate * auctions[auctionId].minRebateIncrementRatio / 1 ether, "Min increment"); // 1 ether = 10**18

        auctions[auctionId].winningProviderFEVMaddress.transfer(auctions[auctionId].rebate); // Repay losing bidder

        auctions[auctionId].winningProviderFEVMaddress = payable(msg.sender);
        auctions[auctionId].winningProvider = provider;
        auctions[auctionId].rebate = msg.value;
    }

    function cancel(uint256 auctionId) external nonReentrant {
        require(msg.sender == auctions[auctionId].clientFEVMaddress, "Not owner");
        require(auctions[auctionId].winningProviderFEVMaddress == address(0), "Bidder exists");
        auctions[auctionId].clientFEVMaddress.transfer(auctions[auctionId].clientSecurityDeposit);
        auctions[auctionId].clientSecurityDeposit = 0; // Redundant but safe
        delete auctions[auctionId];
    }

    function liquidate(uint256 auctionId) external nonReentrant {
        require(block.timestamp > auctions[auctionId].realizationDeadline, "Too early");
        if (auctions[auctionId].winningProviderFEVMaddress == address(0)) {
            // Cancel auction
            auctions[auctionId].clientFEVMaddress.transfer(auctions[auctionId].clientSecurityDeposit);
        } else if (isDealOpen(auctions[auctionId].dealId) || !isCorrectDealProvider(auctionId)) {
            // Client loses security deposit
            auctions[auctionId].winningProviderFEVMaddress.transfer(auctions[auctionId].clientSecurityDeposit);
        } else { // Deal is activated
            // Pay client rebate and security deposit
            auctions[auctionId].clientFEVMaddress.transfer(auctions[auctionId].rebate + auctions[auctionId].clientSecurityDeposit);
            auctions[auctionId].rebate = 0; // Redundant but safe
        }
        auctions[auctionId].clientSecurityDeposit = 0; // Redundant but safe
        delete auctions[auctionId];
    }
}