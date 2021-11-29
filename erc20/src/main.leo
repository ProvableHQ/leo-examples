// mapping(address => mapping(address => uint256)) private _allowances 
//  uint256 private _totalSupply;

//
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
    approvals: mapping(address => u32), // Could possibly represent with Map/PtrMap<address, u32>


    function transfer(self, to: address, amount: u32) -> (Self, Self) {
        console.assert(amount <= self.amount);
        // Do we need to check that the record.owner is in fact the owner of the record?

        let rec1 = Self {
            owner: self.owner,
            amount: self.amount - amount,
            name: self.name,
            symbol: self.symbol,
        };
        let rec2 = Self {
            owner: to,
            amount,
            name: self.name,
            symbol: self.symbol,
        };

        return (rec1, rec2);
    }

    function merge(self, other: Self) -> Self {
        console.assert(self.owner == other.owner);

        return Self {
            owner: self.owner,
            amount: self.amount + other.amount,
            name: self.name,
            symbol: self.symbol,
        };
    }

    function approve(self, to: address, amount: u32) -> Self {
        // How should the checks be enforced on chain?
        // What if you go the Rust route with Results (but instead you are forced to handle the error case)
        // @enforced annotation on console.asserts?
        // program identity is important.
        console.assert(self.amount <= amount);
        self.approvals[to] = amount;

        return self;
    }
}

// The 'erc20' main function.
function main(a: u32, b: u32) -> u32 {
    let c: u32 = a + b;
    return c;
}
