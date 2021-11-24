// mapping(address => mapping(address => uint256)) private _allowances 
//  uint256 private _totalSupply;

//
//circuit Record {
//    payload: [u8; 128];
//    // other components that we want the Leo code to have access to
//}
//that represents (part of) a record and a type
//circuit TransitionInput {
//    record1: Record;
//    record2: Record;
//    record1_present: bool;
//    record2_present: bool;
//}

// size should be <= 128B.
circuit BalanceRecord {
    owner: address,
    amount: u32,
    name: [char; 64],
    symbol: [char; 16]
    @storage
    approvals: mapping(address => u32),
}

function transfer(record: BalanceRecord, to: address, amount: u32) -> (BalanceRecord, BalanceRecord) {
    console.assert(amount <= record.amount);
    // Do we need to check that the record.owner is in fact the owner of the record?

    let rec1 = BalanceRecord {
        owner: record.owner,
        amount: record.amount - amount,
    };
    let rec2 = BalanceRecord {
        owner: to,
        amount: amount,
     };

     return (rec1, rec2);
}

function merge(rec1: BalanceRecord, rec2: BalanceRecord) -> BalanceRecord {
    console.assert(rec1.owner == rec2.owner);

    return BalanceRecord {
        owner: rec1.owner,
        amount: rec1.amount + rec2.amount,
    };
}

function approve(rec: BalanceRecord, to: address, amount: u32) -> BalanceRecord {
    // How should the checks be enforced on chain?
    // What if you go the Rust route with Results (but instead you are forced to handle the error case)
    // @enforced annotation on console.asserts?
    // program identity is important.
    console.assert(rec.amount <= amount);
    rec.approvals[to] = amount;

    return rec;
}


// The 'erc20' main function.
function main(a: u32, b: u32) -> u32 {
    let c: u32 = a + b;
    return c;
}
