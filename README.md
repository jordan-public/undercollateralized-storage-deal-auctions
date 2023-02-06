Check if auction exists:
```
hh exists --contract "0xdFbFBD5f5d3f1805FAA3f085b0a52416bc40863d" --dealid 863
```

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

Switch to Account1 (0x8B5c5694E93aDc4607221F5b3bc6f1BBfbd8fB57):
```
cp .env.account1 .env
```

Switch to Account2 (0x24652C001E3f1Bfe140aF69c31a499F332Dd4D2D):
```
cp .env.account2 .env
```

Switch to Account3 (0x440BF886fF4Ee666F17F232dD4F2deeba3dcDf4C):
```
cp .env.account3 .env
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
hh set-auction-dealid --auctionid 797 --dealid 1000
```
