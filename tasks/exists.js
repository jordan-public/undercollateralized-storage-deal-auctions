task(
    "exists",
    "Checks for existance and verification of a deal."
  )
    .addParam("contract", "The address of the StorageRebateAuctions contract")
    .addParam("dealid", "The id of the deal with the completed bounty")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const dealid = taskArgs.dealid
        const networkId = network.name
        console.log("Checking for existance of deal on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a DealRewarder contract factory
        const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const storageRebateAuctions = await StorageRebateAuctions.attach(contractAddr)
        
        //send a transaction to call claim_bounty() method
        transaction = await storageRebateAuctions.exists(dealid);
        console.log("Transaction: ", transaction);
        //await transaction.wait();
        //console.log("Transaction: ", transaction);
        console.log("Complete!")
    })