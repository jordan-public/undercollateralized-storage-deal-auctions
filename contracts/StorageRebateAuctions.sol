// SPDX-License-Identifier: Apache-2.0 and MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

contract StorageRebateAuctions is ReentrancyGuard {
    struct ReqDescr {
        bytes cidraw; 
        uint256 size;        
        int64 termDuration;
    }

    struct Auction {
        ReqDescr request;
        address payable clientFEVMaddress;
        address payable winningProviderFEVMaddress;
        uint64 winningProvider;
        uint256 clientSecurityDeposit;
        uint256 minRebate;
        uint256 rebate;
        uint256 minRebateIncrementRatio; // 18 decimals; 1.05 * 10**18 would mean 5%
        uint256 closingTime;
        uint256 realizationDeadline;
        uint64 dealId;
    }
    Auction[] public auctions;

    function numAuctions() external view returns (uint256) { return auctions.length; }

    function isDealExsistent(uint64 dealId) public /*view*/ returns (bool) {
        // Not good because MarketAPI.getDealLabel is internal:
        // if (dealId == 0) return false; // Not initialized
        // try MarketAPI.getDealLabel(dealId) returns (MarketTypes.GetDealLabelReturn memory l) {
        //     return true;
        // } catch { // No such deal
        //     return false;
        // }

        // As suggested on Discord - I am not convinced
        MarketTypes.GetDealVerifiedReturn memory v = MarketAPI.getDealVerified(dealId);
        return v.verified;
    }

    function isCorrectDealProvider(uint256 auctionId) internal /*view*/ returns (bool) {
        MarketTypes.GetDealProviderReturn memory p = MarketAPI.getDealProvider(auctions[auctionId].dealId);
        return p.provider == auctions[auctionId].winningProvider;
    }

    function isCorrectDealDuration(uint256 auctionId) internal /*view*/ returns (bool) {
        MarketTypes.GetDealTermReturn memory t = MarketAPI.getDealTerm(auctions[auctionId].dealId);
        return t.end - t.start >= auctions[auctionId].request.termDuration;
    }

    function isCorrectDeal(uint256 auctionId) internal /*view*/ returns (bool) {
        MarketTypes.GetDealDataCommitmentReturn memory c = MarketAPI.getDealDataCommitment(auctions[auctionId].dealId);
        return keccak256(c.data) == keccak256(auctions[auctionId].request.cidraw) && c.size == auctions[auctionId].request.size;
    }

    function isDealActivated(uint64 dealId) public /*view*/ returns (bool) {
        MarketTypes.GetDealActivationReturn memory a = MarketAPI.getDealActivation(dealId);
        return a.activated != -1;
    }

    function isValid(uint256 auctionId) external view returns (bool) {
        return auctionId < auctions.length && !isCanceled(auctionId);
    }

    function startNew(
        bytes calldata cidraw,
        uint256 size,    
        int64 termDuration,
        uint256 minRebate,
        uint256 minRebateIncrementRatio,
        uint256 closingTime,
        uint256 realizationDeadline
    ) external payable returns (uint256 auctionId) {
        require(closingTime > block.timestamp, "Bad closing time");
        require(realizationDeadline > closingTime, "Bad realization deadline");
        require(minRebateIncrementRatio > 1 ether, "Bids must increase");
        require(msg.value > 0, "No security deposit");
        auctionId = auctions.length;
        auctions.push();
        auctions[auctionId].request.cidraw = cidraw;
        auctions[auctionId].request.size = size;
        auctions[auctionId].request.termDuration = termDuration;
        auctions[auctionId].clientFEVMaddress = payable(msg.sender);
        // auctions[auctionId].winningProviderFEVMaddress = address(0);
        // auctions[auctionId].winningProvider = 0;
        auctions[auctionId].clientSecurityDeposit = msg.value;
        auctions[auctionId].minRebate = minRebate;
        // auctions[auctionId].rebate = 0; 
        auctions[auctionId].minRebateIncrementRatio = minRebateIncrementRatio;
        auctions[auctionId].closingTime = closingTime;
        auctions[auctionId].realizationDeadline = realizationDeadline;
    }

    function bid(uint256 auctionId, uint64 provider) external payable nonReentrant {
        require(block.timestamp <= auctions[auctionId].closingTime, "Auction ended");
        require(msg.value >= auctions[auctionId].minRebate, "Min rebate");
        require(auctions[auctionId].rebate == 0 || msg.value >= auctions[auctionId].rebate * auctions[auctionId].minRebateIncrementRatio / 1 ether, "Min increment"); // 1 ether = 10**18
        require(!isCanceled(auctionId), "Auction canceled");

        if (auctions[auctionId].winningProviderFEVMaddress != address(0)) auctions[auctionId].winningProviderFEVMaddress.transfer(auctions[auctionId].rebate); // Repay losing bidder

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

    function isCanceled(uint256 auctionId) public view returns (bool) {
        return auctions[auctionId].clientSecurityDeposit == 0;
    }

    function setDealId(uint256 auctionId, uint64 dealId) external {
        // Client must enter dealId before deadline to prove that the deal was correctly activated
        // This must be done after activating the deal, otherwise client can lose security deposit and rebate
        require(msg.sender == auctions[auctionId].clientFEVMaddress, "Not authorized");
        require(auctions[auctionId].dealId == 0, "Cannot override once set");
        require(block.timestamp > auctions[auctionId].closingTime, "Auction still active");
        require(block.timestamp <= auctions[auctionId].realizationDeadline, "Deadline passed");
        auctions[auctionId].dealId = dealId;
    }

    function liquidate(uint256 auctionId) external nonReentrant {
        require(block.timestamp > auctions[auctionId].closingTime, "Too early");
        require(!isCanceled(auctionId), "Auction is canceled");
        if (auctions[auctionId].winningProviderFEVMaddress == address(0)) {
            // Cancel auction - no bidders
            auctions[auctionId].clientFEVMaddress.transfer(auctions[auctionId].clientSecurityDeposit);
        } else if (auctions[auctionId].dealId != 0 && 
                    isDealExsistent(auctions[auctionId].dealId) && 
                    isCorrectDealProvider(auctionId) && 
                    isCorrectDeal(auctionId) && 
                    isCorrectDealDuration(auctionId) && 
                    isDealActivated(auctions[auctionId].dealId)) { // Deal is activated as specified 
            // Pay client rebate and security deposit
            auctions[auctionId].clientFEVMaddress.transfer(auctions[auctionId].rebate + auctions[auctionId].clientSecurityDeposit);
            auctions[auctionId].rebate = 0; // Redundant but safe
        } else {
            require(block.timestamp > auctions[auctionId].realizationDeadline, "Too early to slash"); 
            // Client did not start deal as agreed
            // Client loses security deposit
            auctions[auctionId].winningProviderFEVMaddress.transfer(auctions[auctionId].clientSecurityDeposit);
        }
        auctions[auctionId].clientSecurityDeposit = 0; // Redundant but safe
        delete auctions[auctionId];
    }
}