#!/bin/bash

// hh exists --contract "0xdFbFBD5f5d3f1805FAA3f085b0a52416bc40863d" --dealid 863
hh start-new-auction --contract "0xdFbFBD5f5d3f1805FAA3f085b0a52416bc40863d" --dealid 3 --minrebate "1000000000000000000" --incr "10000000000000000" --closingtime 1675511 --realizationdeadline 1675598
hh list-auctions --contract "0xdFbFBD5f5d3f1805FAA3f085b0a52416bc40863d"