const CID = require('cids')

task(
    "bal",
    "Get address balance."
  )
  .setAction(async (taskArgs) => {
    //store taskargs as useable variables
    const auctionid = taskArgs.auctionid;
    const provider = taskArgs.provider;
    const amount = taskArgs.amount;

    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider);
    console.log("Address", wallet.address, "balance:", (await wallet.getBalance()).toString());
  })