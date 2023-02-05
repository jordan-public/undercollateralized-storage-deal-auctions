require("dotenv").config()

task(
    "show-all",
    "Shows values collected in store-all."
  )
    .setAction(async (taskArgs) => {
        const CONTRACT = "0xa27edE780672870A0191360485606099Ab1A1490" // process.env.CONTRACT

        //store taskargs as useable variables
        const dealID = taskArgs.dealid
        
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        const FilecoinMarketConsumer = await ethers.getContractFactory("FilecoinMarketConsumer", wallet)
        const filecoinMarketConsumer = await FilecoinMarketConsumer.attach(CONTRACT)
        
        //send transaction to call storeAll() method
        console.log("dealLabel", await filecoinMarketConsumer.dealLabel());
        console.log("dealClientActorId", (await filecoinMarketConsumer.dealClientActorId()).toString());
        console.log("dealProviderActorId", (await filecoinMarketConsumer.dealProviderActorId()).toString());
        console.log("isDealActivated", await filecoinMarketConsumer.isDealActivated());
        console.log("dealCommitment", (await filecoinMarketConsumer.dealCommitment()).toString());
        console.log("dealTerm", (await filecoinMarketConsumer.dealTerm()).toString());
        console.log("dealPricePerEpoch", (await filecoinMarketConsumer.dealPricePerEpoch()).toString());
        console.log("clientCollateral", (await filecoinMarketConsumer.clientCollateral()).toString());
        console.log("providerCollateral", (await filecoinMarketConsumer.providerCollateral()).toString());
        console.log("activationStatus", (await filecoinMarketConsumer.activationStatus()).toString());
        console.log("Complete!")
    })