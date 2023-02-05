const CID = require('cids')

task(
    "start-new-auction",
    "Starts a new auction."
  )
  .addParam("piececid", "The piece CID of the data to be stored")
  .addParam("size", "The size of data to be stored")
  .addParam("duration", "The minimum duration of data to be stored")
  .addParam("minrebate", "Minumum rebate")
  .addParam("incr", "Rebate increment")
  .addParam("closingtime", "Closing time in minutes")
  .addParam("realizationdeadline", "Realization deadline in minutes")
  .addParam("secdep", "Security deposit")
  .setAction(async (taskArgs) => {
    //store taskargs as useable variables
    let piececid = taskArgs.piececid;
    if (!piececid.startsWith("0x")) {
      //convert piece CID string to hex bytes
      const piececidHexRaw = new CID(piececid).toString('base16').substring(1)
      piececid = "0x00" + piececidHexRaw
      console.log("piececid Hex bytes are:", piececid) 
    }
    const size = taskArgs.size;
    const duration = taskArgs.duration;
    const minRebate = taskArgs.minrebate;
    const incr = taskArgs.incr;
    const tClosing = parseInt(taskArgs.closingtime, 10);
    const tDeadline = parseInt(taskArgs.realizationdeadline, 10);
    const secdep = taskArgs.secdep;

    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider);
    const StorageRebateAuctions = await ethers.getContractFactory("StorageRebateAuctions", wallet);
    const storageRebateAuctions = await StorageRebateAuctions.attach(process.env.CONTRACT)
       
    const transaction = await storageRebateAuctions.startNew(piececid, size, duration, minRebate, incr,
                                                              tClosing * 60 + Math.floor(new Date().getTime() / 1000),
                                                              tDeadline * 60 + Math.floor(new Date().getTime() / 1000),
                                                              {gasLimit: 1000000000, value: secdep});
    const receipt = await transaction.wait();
    console.log("Complete!")
  })