task(
  "set-auction-dealid",
  "Client sets dealId for auction to prove deal is realized."
)
.addParam("auctionid", "Auction id")
.addParam("dealid", "Deal id")
.setAction(async (taskArgs) => {
  //store taskargs as useable variables
  const auctionid = taskArgs.auctionid;
  const dealid = taskArgs.dealid;
  
  const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider);
  const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet);
  const storageRebateAuctions = await StorageRebateAuctions.attach(process.env.CONTRACT)
     
  const transaction = await storageRebateAuctions.setDealId(auctionid, dealid, {gasLimit: 1000000});
  const receipt = await transaction.wait();
  console.log("Complete!");
})