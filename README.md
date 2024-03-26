# About AuctionProject-solidity

// the auction smart contract

// 1) -> smart contract for a decentralized auction like ebay alternative

// 2) the auction has owner ,a start and a end date;
// 3) the owner can cancel the auction if there is an emergency or can finalize the auction after its end time;
// 4) people are sending ETH by calling a function called placebid(). the sender address and the value sent to the auction will be stored in mapping variable called bids.
// 5) users are incentivized to bid the maximum theyre willing to pay , but they are not bound to that full amount , but rather to the privious hoghest bid plus an increment.
//     The contract will automatically bid up to a given amount;
// 6) the highestBindingBid is the selling price and the highestBidder the person who won the aution
// 7) after the auction ends the owner gets the highestBindingBid and everybody else withdraws their own amount;

//----------------------------------------------------------------------------------------------------------------------------------------------------
