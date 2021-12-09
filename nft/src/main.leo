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

// Hashes.
// ARC-721 is not tied to a specific hash function,
// but since the Merkle tree roots consists of 256 bits,
// the hash function must return 256-bit hashes.
// We introduce a type alias for hashes, for greater clarity.
type hash = [u8; 32]; // 256 bits

////////////////////////////////////////////////////////////////////////////////

// Hash function.
// This is a placeholder for some hash function in the library.
// In this file, we use the same hash function
// for signature verification (see below) and for Merkle trees;
// we may want to use two different hash functions,
// but that is easy to change.
// A hash function takes as input a variable number of bytes.
// In current Leo, we can pass a sufficiently large array
// and a length that says how many elements are actually used;
// we assume that the result is always 256 bits (i.e. 32 bytes),
// which is consistent with the Merkle tree roots in the NFT application.
function compute_hash(data: [u8; 256], len: u32) -> hash {
    // check (at compile time) that the length is within bounds:
    console.assert(len <= 256);
    // just a placeholder, but we want it to depend on the inputs
    // so it doesn't get optimized away (if it were a constant):
    let result: u8 = 0;
    for i in 0..256 {
        if i < len && data[i] > 128 {
            result += 1;
        }
    }
    return [result; 32];
}


// Instead of taking a fixed-size array and a length,
// a function like this could take just an array of unspecified size,
// which different calls would resolve differently.
// But this resolution may not be yet supported in Leo,
// so for now we choose the approach in the code above.
// We will try the array of unspecified size at some point.

////////////////////////////////////////////////////////////////////////////////

// Signatures.
// The exact type of a signature depends on the signature algorithm.
// We just use 512 bits (i.e. 64 bytes) for now.
// See verify_signature below for more information.
type signature = [u8; 64]; // 512 bits

////////////////////////////////////////////////////////////////////////////////

// Signature verification.
// Presumably functions to verify signatures will be available
// in the Leo library.
// For now we just put a placeholder here.
// A reasonable interface for a signature verification function
// is to take as inputs
// a hash (of the data being signed),
// the signature (of some type; see type signature above),
// and an address of the purported signer;
// the output is a boolean.
// This would work by deriving a public key from the address
// and checking that the signature is valid for the hashed data
// with respect to the public key.
function verify_signature(hash: hash,
                          signature: signature,
                          signer: address) -> bool {
    // just a placeholder, but we want it to depend on the inputs
    // so it doesn't get optimized away (if it were a constant):
    return signature == [...hash, ...signer.to_bytes_be()];
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
// This must be consistent with the type alias of hashes.
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
circuit nft_record {

    merkle_root: merkle_root;

    // Serialize NFT record to Aleo record.
    // We put the 32 bytes at the beginning of the payload
    // and fill the remaining payload bytes with 0.
    function serialize(self) -> record {
        return record {
            payload: [...self.merkle_root, ...[0; 96]]
        };
    }

    // Deserialize NFT record from Aleo record.
    // We take the first 32 bytes from the payload;
    // we also check (at compile time) that the remaining payload bytes are 0.
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
// a caller address,
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
    caller: address;
    token_id: token_id;
    address1: address;
    address2: address;
    amount: u128;

    // Serialize the message.
    // This is so we can compute a hash, for signature verification.
    // We convert every member variable to bytes
    // (in little endian, but big endian would be also fine)
    // and we concatenate them.
    // This gives exactly 145 bytes.
    function serialize(self) -> [u8; 145] {
        return [self.opcode,
                ...self.caller.to_bytes_le(),
                ...self.token_id,
                ...self.address1.to_bytes_le(),
                ...self.address2.to_bytes_le(),
                ...self.amount.to_bytes_le()];
    }

    // Verify a message signature.
    // We hash the message
    // (padding the data array with 111 bytes to make 256 bytes,
    // but passing the length 145 to the hash function)
    // and we call the signature verification function,
    // taking the signer directly from the message.
    function verify_signature(self, signature: signature) -> bool {
        let data = [...self.serialize(), ...[0; 111]];
        let hash = compute_hash(data, 145);
        return verify_signature(hash, signature, self.caller);
    }
}

////////////////////////////////////////////////////////////////////////////////

// Merkle path element.
// See the merkle_path type below for an explanation of this type.

circuit merkle_path_element {
    hash: hash;
    left: bool;
}

////////////////////////////////////////////////////////////////////////////////

// Merkle paths.
// A Merkle path is a sequence of hashes that correspond to a Merkle leaf.
// With reference to the Merkle tree illustrated in ARC-721,
// the Merkle path of Leaf 3 is the sequence of Hash 4 and Hash 1,2,
// in that order (i.e. the path goes up the tree).
// The significance of the path of a Merkle leaf is that
// the Merkle root can be calculated from the leaf and the path:
// for Leaf 3, calculate its hash Hash 3,
// then concatenate that with Hash 4 from the path,
// hash the concatenation to obtain Hash 3,4,
// concatenate that with Hash 1,2 from the path,
// and hash the concatenation to obtain Hash 1,2,3,4, i.e. the root.
// However, the hashes alone are not enough:
// we need to know whether each hash in the path has to be concatenated
// on the left of the current hash or on the right:
// this motivates the definition of the merkle_path_element type earlier,
// where the member variable left is
// true if the hash of the path element is concatenated to the left,
// false if the hash of the path element is concateneted to the right
// (an enumeration would be more elegant than a boolean,
// but Leo currently does not support enumerations).
// A Merkle tree is a binary tree that is always regarded as being complete,
// by using all-zero leaves for actually missing leaves.
// The length n of a path is the depth of the tree,
// measured in distance between leaf hashes and root hash;
// thus the tree contains at most 2^n (non-zero) leaves.
// We must pick some number for n here, so we pick n,
// which may very well be too small, but it is easily changed.
// (Thus, each token can have 65,536 leaves asserting ownership.)
type merkle_path = [merkle_path_element; 16];

////////////////////////////////////////////////////////////////////////////////

// TODO: add functions for mint, transfer, approve, lock, unlock, burn

////////////////////////////////////////////////////////////////////////////////

// TODO: this is just a placeholder for now
function main(a: u32, b: u32) -> u32 {
    let c: u32 = a + b;
    return c;
}
