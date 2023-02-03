task(
    "start-new-auction",
    "Starts a new auction."
  )
  .addParam("contract", "The address of the StorageRebateAuctions contract")
  .addParam("dealid", "The id of the deal with the completed bounty")
  .addParam("minrebate", "minimal rebate")
  .addParam("incr", "Rebate increment")
  .addParam("closingtime", "Closing time")
  .addParam("realizationdeadline", "Realization deadline")
  .setAction(async (taskArgs) => {
      //store taskargs as useable variables
        const contractAddr = taskArgs.contract;
        const dealid = taskArgs.dealid;
        const minRebate = taskArgs.minrebate;
        const incr = taskArgs.incr;
        const tClosing = taskArgs.closingtime;
        const tDeadline = taskArgs.realizationdeadline;

        const networkId = network.name
        console.log("Checking for existance of deal on network", networkId);


        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a DealRewarder contract factory
        const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const storageRebateAuctions = await StorageRebateAuctions.attach(contractAddr)
        
        //send a transaction to call claim_bounty() method
        const transaction = await storageRebateAuctions.startNew(dealid, minRebate, incr, tClosing, tDeadline, {gasLimit: 1000000000});
        const receipt = await transaction.wait();
        console.log("Complete!")
    })