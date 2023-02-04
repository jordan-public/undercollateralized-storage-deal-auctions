task(
    "list-auctions",
    "Lists all auctions."
  )
    .addParam("contract", "The address of the StorageRebateAuctions contract")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const dealid = taskArgs.dealid
        const networkId = network.name
        console.log("Listing auctions.", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a DealRewarder contract factory
        const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const storageRebateAuctions = await StorageRebateAuctions.attach(contractAddr)
        
        //send a transaction to call claim_bounty() method
        const auctionCount = await storageRebateAuctions.numAuctions();
        console.log("Auction Count: ", auctionCount.toString());
        console.log("Complete!")
    })