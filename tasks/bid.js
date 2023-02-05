task(
    "bid",
    "Bid on auction."
  )
  .addParam("auctionid", "Auction id")
  .addParam("provider", "Provider id")
  .addParam("amount", "amount")
  .setAction(async (taskArgs) => {
    //store taskargs as useable variables
    const auctionid = taskArgs.auctionid;
    const provider = taskArgs.provider;
    const amount = taskArgs.amount;

    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider);
    const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet);
    const storageRebateAuctions = await StorageRebateAuctions.attach(process.env.CONTRACT)
       
    const transaction = await storageRebateAuctions.bid(auctionid, provider, {gasLimit: 100000000, value: amount});
    const receipt = await transaction.wait();
    console.log("Complete!")
  })