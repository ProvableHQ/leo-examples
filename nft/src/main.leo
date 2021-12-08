// This is work in progress towards representing the NFT application in Leo.
// The NFT application is at https://github.com/AleoHQ/nft,
// whose README.md file is ARC-721,
// i.e. a standard specification of NFTs on Aleo.
// The Leo code below is based on ARC-721
// as well the Rust code in the NFT repo.

////////////////////////////////////////////////////////////////////////////////

// Aleo blockchain records.
// This type will be in the Leo standard library, but for now we define it here.
// This could have additional member variables,
// but we only need the payload for this NFT application.
circuit record {
    payload: [u8; 128];
}

////////////////////////////////////////////////////////////////////////////////

// Token IDs.
// Each token has an ID.
// Token IDs can be treated as opaque in the Leo code;
// ARC-721 shows two possible ways of structuring them,
// but that seems more relevant to external tools.
// In any case, ARC-721 prescribes that they consist of 256 bits.
type token_id = [u8; 32]; // 256 bits

////////////////////////////////////////////////////////////////////////////////

// There is a Merkle tree for each token (i.e. for each token ID),
// which keeps track of who owns how much of the token.
// (Thus, a token ID does not identify just one token instance,
// but possibly many instances of that token;
// presumably, the non-fungibility applies across different tokens,
// but not across instances of the same token.)
// The Leo application does not store the Merkle trees:
// those are stored outside the blockchain, in fact.
// It is the (offchain) NFT application that stores the Merkle trees.
// The Leo application manipulates roots and leaves of these Merkle trees
// (see below).

////////////////////////////////////////////////////////////////////////////////

// Merkle tree roots.
// These are hashes, which ARC-721 prescribes to consist of 256 bits.
type merkle_root = [u8; 32]; // 256 bits

////////////////////////////////////////////////////////////////////////////////

// Merkle tree leaves.
// These are according to ARC-721.
// A leaf of this kind says that
// a certain owner (identified by an address)
// has a certain amount (the balance)
// of a certain token (identified by an ID).
// It also optionally says that an operator (identified by an address)
// is authorized to transfer (some amount of) this token (from this leaf);
// if there is no such authorization,
// the operator address could be set to the same as the owner.
// It also includes a flag saying whether this amount of token
// is locked (i.e. cannot be transferred) or not.
circuit merkle_leaf {
    token_id: token_id;
    owner: address;
    operator: address;
    balance: u128;
    is_locked: bool;
}

////////////////////////////////////////////////////////////////////////////////

// NFT records.
// This is a higher-level, application-specific type of records,
// which is serialized/deserialized to/from blockchain records.
// An NFT record consists of just a Merkle tree root,
// which pertains to a specific token (ID).
// The token ID is not represented in the record:
// presumably, the external NFT application keeps track of the records.
// Thus, the Aleo blockchain stores the Merkle tree roots, in records.
// We serialize an NFT record by
// putting the 32 bytes at the beginning of the payload
// and filling the remaining payload bytes with 0.
// Consequently, we deserialize it by taking the first 32 bytes of the payload;
// we also check (at compile time) that the remainign payload bytes are 0.
circuit nft_record {

    merkle_root: merkle_root;

    function serialize(self) -> record {
        return record {
            payload: [...self.merkle_root, ...[0; 96]]
        };
    }

    function deserialize(record: record) -> Self {
        let payload = record.payload;
        for i in 32 .. 128 {
            console.assert(payload[i] == 0);
        }
        return Self {
            merkle_root: payload[0..32]
        };
    }
}

////////////////////////////////////////////////////////////////////////////////

// Opcodes.
// Each NFT operation has a code, which is a number between 0 and 5.
// We introduce a type alias and define it to be u8,
// which is overkill for just 6 values,
// but currently we do not have integer types of smaller range.
// (We could use [bool; 3], but then we would have to encode/decode;
// and we would still have 2 unused values.)
type opcode = u8;

////////////////////////////////////////////////////////////////////////////////

// Messages.
// These are as in ARC-721.
// We really need sum types (e.g. Rust-style enums) for this,
// because different messages have different fields.
// Fortunately, the differences are just slight,
// and thus we can get away with one circuit type consisting of
// an opcode (which identifies the operation),
// a token ID (common to all messages),
// a first address
// (which is the sender for a transfer operation,
// and the owner for all other operations),
// a second address
// (which is the receiver for a transfer operation,
// the operator for an approve operation,
// and could be set to the same as owner for the other operations),
// and an amount
// (which can be set to 0 for lock, unlock, and approve operations).
circuit message {
    opcode: opcode;
    token_id: token_id;
    address1: address;
    address2: address;
    amount: u128;
}

// TODO: add message signature verification

////////////////////////////////////////////////////////////////////////////////

// TODO: add functions for mint, transfer, approve, lock, unlock, burn

////////////////////////////////////////////////////////////////////////////////

// TODO: this is just a placeholder for now
function main(a: u32, b: u32) -> u32 {
    let c: u32 = a + b;
    return c;
}
