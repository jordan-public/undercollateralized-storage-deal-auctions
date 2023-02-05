task(
    "list-auctions",
    "Lists all auctions."
  )
  .setAction(async (taskArgs) => {
    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider);
    const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet);
    const storageRebateAuctions = await StorageRebateAuctions.attach(process.env.CONTRACT);
    
    //send a transaction to call claim_bounty() method
    const auctionCount = await storageRebateAuctions.numAuctions();
    
    for (let i=0; i<auctionCount; i++) {
      const auction = await storageRebateAuctions.auctions(i);
      if (! auction.clientSecurityDeposit.isZero()) {
        console.log("Auction ID:", i);
        console.log("Piece CID:", auction.request.cidraw);
        console.log("Size:", auction.request.size.toString());
        console.log("Min duration:", auction.request.termDuration.toString());
        console.log("clientFEVMaddress:", auction.clientFEVMaddress);
        console.log("winningProviderFEVMaddress:", auction.winningProviderFEVMaddress);
        console.log("winningProvider:", auction.winningProvider.toString());
        console.log("clientSecurityDeposit:", auction.clientSecurityDeposit.toString());
        console.log("minRebate:", auction.minRebate.toString());
        console.log("rebate:", auction.rebate.toString());
        console.log("minRebateIncrementRatio:", auction.minRebateIncrementRatio.toString());
        console.log("closingTime:", new Date(parseInt(auction.closingTime.toString(),10) * 1000).toString());
        console.log("realizationDeadline:", new Date(parseInt(auction.realizationDeadline.toString(),10) * 1000).toString());
        console.log("dealId:", auction.dealId.toString());
        console.log("");
      }
    }
  })