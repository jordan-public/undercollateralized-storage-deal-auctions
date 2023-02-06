Demo 

No auctions yet:
```
hh list-auctions
```

Storage client (account 1) creates auction with security deposit of 1 FIL
(note no dealId entered - for the demo purpose, against client's economic interest let's pretend it does not exist yet):
```
cp .env.account1 .env

hh start-new-auction \
--piececid "baga6ea4seaqagmtyxv5sp5qw35gc4ijcekyg3zzm75dfkissqfs7pqgkohgribq" \
--size "536870912" --duration "1" --minrebate "0" --incr "1100000000000000000" \
--closingtime 10 --realizationdeadline 20 --secdep "1000000000000000000"
```

The auction is there:
```
hh list-auctions
```

Storage provider 1 (account 2) bids 1 FIL:
```
cp .env.account2 .env

hh bid --auctionid 4 --provider 1001 --amount "1000000000000000000"
```

Storage provider 2 (account 3) bids 2 FIL:
```
cp .env.account3 .env

hh bid --auctionid 4 --provider 1000 --amount "2000000000000000000"
```

See the auction status (winning bidder is the storage client 2):
```
hh list-auctions
```

Now wait for the auction to end ...
```
date
```

Client (account 1) sets up and activates deal:
```
cp .env.account1 .env

hh set-auction-dealid --auctionid 4 --dealid 3
```

Anyone (but in this case the storage client liquidates the auction. This distributes the winning provider's rebate to the storage client and also refunds the security deposit):
```
hh bal

hh liquidate-auction --auctionid 4

hh bal
```
