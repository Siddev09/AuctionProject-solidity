// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract Auction {
    address payable public owner;
    uint256 public startBlock;
    uint256 public endBlock;
    string public ipfsHash;
    enum state {
        Started,
        Running,
        Ended,
        Cancled
    }
    state public auctionState;

    uint256 public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint256) public bids;

    uint256 bidIncrement;

    constructor() {
        owner = payable(msg.sender);
        auctionState = state.Running;
        startBlock = block.number;
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 1000000000000000000; //1 ETH
    }

    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function cancelAuction() public onlyOwner {
        auctionState = state.Cancled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == state.Running);
        require(msg.value >= 100);
        uint256 currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;
        if (currentBid <= bids[highestBidder]) {
            highestBindingBid = min(
                currentBid + bidIncrement,
                bids[highestBidder]
            );
        } else {
            highestBindingBid = min(
                currentBid,
                bids[highestBidder] + bidIncrement
            );
            highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() public {
        require(auctionState == state.Cancled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        address payable recipient;
        uint256 value;

        if (auctionState == state.Cancled) {
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            if (msg.sender == owner) {
                recipient = owner;
                value = highestBindingBid;
            } else {
                if (msg.sender == highestBidder) {
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else {
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        bids[recipient] = 0;
        recipient.transfer(value);
    }
}

//withdrawal pattern//

//1)  we dont pro-actively send back the funds tp the users that didint win the auction we'll use the "withdrawal pattern"
//2)  we should only send ETH to a user when he explicitly request it
//3)  this helps us avoiding re-entrance attacks that could cause unexpected behaviour including financial loss for the user
//---------------------------------------------------------------------------------------------------------------------------------------------
