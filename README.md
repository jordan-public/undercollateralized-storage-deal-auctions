# Undercollateralized Storage Deal Auctions

The Filecoin storage providers offer published prices, yet they are reluctant to change these prices too often, so the storage clients can see reliable pricing. However, as the market conditions change quickly from current supply and demand as well as the price of FIL, it is beneficial to both the clients and the storage providers to have more flexible pricing. 

This auction marketplace can mitigate the above problem. 

In addition, the auctions can serve as a good venue for the storage clients and providers to find each other.

Each auction occurs before the Filecoin deals are published. The auction workflow is as follows:

1. Client starts auction with specifics: data cid, size, min. duration, etc. Upon creation of the auction the client also places a security deposit held by the protocol. The auction can be canceled by the client before the first bid is issued.
2. Providers bid, increasing rebates. Each bidder deposits the rebate in the protocol. As the new highest bidder arrives, the protocol refunds the rebate to the previous highest bidder.
3. After auction end and before deadline client must activate deal. At this time the deal shows in the Filecoin registry and is visible in the Filecoin explorers.
4. After deadline auction can be liquidated. Either:
    - The correct deal was activated and client gets the rebate, or
    - Client loses the security deposit

See the file ```.env.example``` to set up the proper private keys and auction contract address in the file ```.env```.

The contract is deployed on the Filecoin EVM using command:
```
hh deploy
```

Here is the list of commands used to operate the auctions:

Start new auction (hex piece CID):
```
hh start-new-auction --piececid "0x000181e203922020033278bd7b27f616df4c2e212222b06de72cff465522528165f7c0ca71cd1406" \
--size "536870912" --duration "1" --minrebate "0" --incr "1000000000000000000" \
--closingtime 10 --realizationdeadline 20 --secdep "10000000000000000"
```

Start new auction:
```
hh start-new-auction --piececid "baga6ea4seaqagmtyxv5sp5qw35gc4ijcekyg3zzm75dfkissqfs7pqgkohgribq" \
--size "536870912" --duration "1" --minrebate "0" --incr "1000000000000000000" \
--closingtime 10 --realizationdeadline 20 --secdep "10000000000000000"
```

List auctions:
```
hh list-auctions

```

Cancel auction (before first bid):
```
hh cancel-auction --auctionid 797
```

Liquidate auction:
```
hh liquidate-auction --auctionid 797
```

Bid:
```
hh bid --auctionid 797 --provider 1000 --amount "10000000000000000"
```

Set auction deal id:
```
hh set-auction-dealid --auctionid 797 --dealid 3
```
