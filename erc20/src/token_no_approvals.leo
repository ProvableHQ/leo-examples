import record.Record;

// size should be <= 128B.
circuit TokenRecord {
    owner: address,
    amount: u32,
    name: [char; 64],
    symbol: [char; 16]

    // Note: we could have some `derive` functionality for this.
    function as_bytes(self) -> [u8; 116] {
        // 32 + 4 + 64 + 16 = 116 bytes
        let owner_bytes = self.owner as [u8; 32];
        let amount_bytes = self.amount as [u8; 4];
        let name_bytes = self.name as [u8; 64];
        let symbol_bytes = self.symbol as [u8; 16];
        return [...owner_bytes, ...amount_bytes, ...name_bytes, ...symbol_bytes];
    }

    // Note: we could have some `derive` functionality for this.
    function from_bytes(bytes: [u8; 116]) -> Self {
        return Self {
            owner: bytes[0..32] as address,
            amount: bytes[32..36] as u32,
            name: bytes[36..100] as [char; 64],
            symbol: bytes[100..116] as [char; 16],
        };
    }


    function transfer(self, to: address, amount: u32) -> (Self, Self) {
        console.assert(amount <= self.amount);
        // Do we need to check that the record.owner is in fact the owner of the record?
        // Generally, this is dependent on the model by which we allow people to access records. 
        // For example, if only the record owner has access to the record, then we do not need a check.
        // If multiple parties may have access to the record, then a check might be desired.

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

}

// Note: Multiple entry points are a desirable feature.

// Commenting out below, because annotation does not exist.
//@transition 
//@transaction
function transfer(rec1: Record, rec2: Record) -> (Record, Record) {
    let tok = TokenRecord::from_bytes(rec1.payload[..116]);
    let to = rec2.payload[0..32] as address;
    let amount = rec2.payload[32..36] as u32;

    let (tok3, tok4) = tok.transfer(to, amount);

    let payload1 = [...tok3.as_bytes() , ...[0u8; 12]];
    let payload2 = [...tok4.as_bytes() , ...[0u8; 12]];

    let rec3 = Record {
        owner: rec1.owner,
        value: rec1.value, 
        payload: payload1,
        program_id: rec1.program_id,
        record_view_key: rec1.record_view_key, 
    };

    let rec4 = Record {
        owner: rec2.owner,
        value: rec2.value, 
        payload: payload2,
        program_id: rec2.program_id,
        record_view_key: rec2.record_view_key,
    };

    return (rec3, rec4);
}

// Commenting out below, because the annotation does not exist.
//@transition
//@transaction
function merge(rec1: Record, rec2: Record) -> Record {
    let tok1 = TokenRecord::from_bytes(rec1.payload[..116]);
    let tok2 = TokenRecord::from_bytes(rec2.payload[..116]);

    let tok3 = tok1.merge(tok2);
    let payload = [...tok3.as_bytes(), ...[0u8; 12]];

    return Record {
        owner: rec1.owner,
        value: rec1.value, 
        payload: payload,
        program_id: rec1.program_id,
        record_view_key: rec1.record_view_key,
    };
}

