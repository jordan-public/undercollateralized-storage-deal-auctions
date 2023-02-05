task(
    "cancel-auction",
    "Cancels the auction."
  )
  .addParam("auctionid", "Auction id")
  .setAction(async (taskArgs) => {
    //store taskargs as useable variables
    const auctionid = taskArgs.auctionid;
    
    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider);
    const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet);
    const storageRebateAuctions = await StorageRebateAuctions.attach(process.env.CONTRACT)
       
    const transaction = await storageRebateAuctions.cancel(auctionid, {gasLimit: 100000000});
    const receipt = await transaction.wait();
    console.log("Auction", auctionid, "canceled!");
  })