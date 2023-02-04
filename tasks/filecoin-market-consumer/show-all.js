task(
    "show-all",
    "Shows values collected in store-all."
  )
    .addParam("contract", "The address of the FilecoinMarketConsumer contract")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const dealID = taskArgs.dealid
        const networkId = network.name
        
        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a FilecoinMarketConsumer contract factory
        const FilecoinMarketConsumer = await ethers.getContractFactory("FilecoinMarketConsumer", wallet)
        //create a FilecoinMarketConsumer contract instance 
        //this is what you will call to interact with the deployed contract
        const filecoinMarketConsumer = await FilecoinMarketConsumer.attach(contractAddr)
        
        //send transaction to call storeAll() method
        console.log("dealLabel", await filecoinMarketConsumer.dealLabel());
        console.log("dealClientActorId", (await filecoinMarketConsumer.dealClientActorId()).toString());
        console.log("dealProviderActorId", (await filecoinMarketConsumer.dealProviderActorId()).toString());
        console.log("isDealActivated", await filecoinMarketConsumer.isDealActivated());
        console.log("Complete!")
    })