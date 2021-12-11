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
    owner: address;
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

// The condition checked in the console.assert is not represented in R1CS.
// This seems okay, as it does not seem a critical check
// that affects the security of the zero-knowledge proof.
// In R1CS, any len > 256 would be treated the same as 256.

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

    // Create a new leaf with a given token ID and owner.
    // We also set the operator to be the same as the owner,
    // to signify that there is no separate operator
    // (currently we need to put some address there,
    // but see discussion about this in is_empty()).
    // We set balance to 0 and lock status to false.
    function new(token_id: token_id, owner: address) -> Self {
        return Self {
            token_id,
            owner,
            operator: owner,
            balance: 0,
            is_locked: false
        };
    }

    // Serialize the leaf.
    // This is so we can compute a hash, for Merkle trees.
    // We serialize and concatenate the member variables.
    // We use little endian, but big endian would be fine too.
    // The serialized data is 113 bytes.
    function serialize(self) -> [u8; 113] {
        return [...self.token_id,
                ...self.owner.to_bytes_le(),
                ...self.operator.to_bytes_le(),
                ...self.balance.to_bytes_le(),
                ...self.is_locked.to_bytes_le()];
    }

    // Hash of a leaf.
    // This is at the lowest level of the hashes in Merkle trees.
    function hash(self) -> hash {
        let data = [...self.serialize(), ...[0; 143]];
        return compute_hash(data, 113);
    }

    // Test if the leaf is empty.
    // ARC-721 mentions a notion of empty leaf;
    // in fact, since Merkle trees must be complete,
    // there must be a notion of empty leaf.
    // For now we regard a leaf as empty if it has
    // an all-zero token ID, 0 balance, and false locking status;
    // we ignore the owner and operator fields.
    // This should be done in a cleaner way,
    // in particular by allowing "zero" addresses
    // (e.g. by using a byte array as owner and operator,
    // which either is all zeros or is a serialized address;
    // in the future we could use an option address type,
    // but this is currently not supported in Leo).
    function is_empty(self) -> bool {
        return self.token_id == [0; 32] &&
               self.balance == 0 &&
               self.is_locked == false;
    }

    // Increment leaf balance.
    // Do it safely, i.e. only if the new balance fits in u128.
    // Return a boolean saying if the increment is successful.
    // The balance is unchanged if the boolean is false.
    function increment(&self, amount: u128) -> bool {
        if amount > 340282366920938463463374607431768211455u128 - self.balance {
            return false;
        } else {
            self.balance += amount;
            return true;
        }
    }

    // Decrement leaf balance.
    // Do it safely, i.e. only if the amount does not exceed the balance.
    // Return a boolean saying if the decrement is successful.
    // The balance is unchanged if the boolean is false.
    function decrement(&self, amount: u128) -> bool {
        if amount > self.balance {
            return false;
        } else {
            self.balance -= amount;
            return true;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

// NFT records.
// This is a higher-level, application-specific type of records,
// which is serialized/deserialized to/from blockchain records.
// An NFT record consists of an owner,
// and  Merkle tree root, which pertains to a specific token (ID).
// The token ID is not represented in the record:
// presumably, the external NFT application keeps track of the records.
// Thus, the Aleo blockchain stores the Merkle tree roots, in records.
circuit nft_record {

    owner: address;
    root: merkle_root;

    // Create an NFT record with the given owner and root.
    function new(owner: address, root: merkle_root) -> Self {
        return Self { owner, root };
    }

    // Serialize NFT record to Aleo record.
    // We put the 32 bytes at the beginning of the payload
    // and fill the remaining payload bytes with 0.
    function serialize(self) -> record {
        return record {
            owner: self.owner,
            payload: [...self.root, ...[0; 96]]
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
            owner: record.owner,
            root: payload[0..32]
        };
    }
}

// The condition checked in the console.assert is not represented in R1CS.
// This seems okay, as it does not seem a critical check
// that affects the security of the zero-knowledge proof.
// In R1CS, any record with non-zero bytes after the first 32
// is treated the same as if they were zero.

////////////////////////////////////////////////////////////////////////////////

// Opcodes.
// Each NFT operation has a code, which is a number between 0 and 5.
// We introduce a type alias and define it to be u8,
// which is overkill for just 6 values,
// but currently we do not have integer types of smaller range.
// (We could use [bool; 3], but then we would have to encode/decode;
// and we would still have 2 unused values.)
type opcode = u8;

const opcode_mint: opcode = 0;
const opcode_transfer: opcode = 1;
const opcode_approve: opcode = 2;
const opcode_lock: opcode = 3;
const opcode_unlock: opcode = 4;
const opcode_burn: opcode = 5;

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

// Calculate a Merkle root from a Merkle leaf and a Merkle path.
// This realizes the calculation described for the type merkle_path.
// We initialize a running hash with the hash of the leaf,
// and then we go through the elements of the path in order:
// we concatenate the running hash with the path hash,
// and update the running hash with the result.
// The final hash is returned.
function compute_root(leaf: merkle_leaf, path: merkle_path) -> merkle_root {
    let hash = leaf.hash();
    for i in 0..16 {
        let element = path[i];
        let data = element.left ?
                   [...element.hash, ...hash, ...[0; 192]] :
                   [...hash, ...element.hash, ...[0; 192]];
        hash = compute_hash(data, 64);
    }
    return hash;
}

////////////////////////////////////////////////////////////////////////////////

// The description of the operations (mint, transfer, etc.) in ARC-721
// suggests that they are predicates, i.e. boolean-valued functions.
// Each takes as arguments a record, a message, a signature, and more
// (where 'more' varies across the operations),
// and ensures that the arguments satisfy certain conditions.
// Indeed, all these predicates in ARC-721
// take the new Merkle root as the last argument,
// suggesting that it is calculated outside.
// An alternative could be to have Leo functions that calculate the new root.
// However, since the Merkle trees are stored outside the blockchain,
// it seems that it is the tasks of external non-Leo code
// to update the Merke trees, including the roots (one per token).
// Thus, we introduce Leo boolean-valued functions for the operations
// that perform all the operations' checks.

////////////////////////////////////////////////////////////////////////////////

// Check the conditions of the mint operation.
// The steps indicated in the comments are the ones in ARC-721.
// Here message.address2 is not used, which is reasonable because
// it is a dummy message component for a mint operation.
// Should message.address1 be checked against leaf.owner?
// Should we check that the leaf (if not empty) is not locked?
function check_mint(record: record,
                    message: message,
                    signature: signature,
                    path: merkle_path,
                    leaf: merkle_leaf,
                    new_root: merkle_root) -> bool {
    let nftrec = nft_record::deserialize(record);
    let sig_ok = message.verify_signature(signature); // step 1
    let op_ok = message.opcode == opcode_mint; // step 2
    let caller_ok = message.caller == nftrec.owner; // step 3
    let leaf_ok = true;
    if !leaf.is_empty() { // step 4
        leaf_ok = compute_root(leaf, path) == nftrec.root;
    }
    if leaf.is_empty() { // step 5
        leaf = merkle_leaf::new(message.token_id, message.address1);
        // (message.address1 is owner for mint operation)
    }
    let token_ok = leaf.token_id == message.token_id; // step 6
    let inc_ok = leaf.increment(message.amount); // step 7
    let new_root_ok = compute_root(leaf, path) == new_root; // step 8
    return
        sig_ok &&
        op_ok &&
        caller_ok &&
        leaf_ok &&
        token_ok &&
        inc_ok &&
        new_root_ok;
}

////////////////////////////////////////////////////////////////////////////////

// Check the conditions of the transfer operation.
// The steps indicated in the comments are the ones in ARC-721.
// Should message.address1 be checked against leaf_0.owner?
// Should message.address2 be checked against leaf_1.owner?
// Should we check that leaf_1 (if not empty) is not locked?
function check_transfer(record: record,
                        message: message,
                        signature: signature,
                        path_0: merkle_path,
                        path_1: merkle_path,
                        leaf_0: merkle_leaf,
                        leaf_1: merkle_leaf,
                        new_root: merkle_root) -> bool {
    let nftrec = nft_record::deserialize(record);
    let sig_ok = message.verify_signature(signature); // step 1
    let op_ok = message.opcode == opcode_transfer; // step 2
    let caller_ok = // step 3
        message.caller == nftrec.owner ||
        message.caller == leaf_0.owner ||
        message.caller == leaf_0.operator;
    let leaf_0_ok = compute_root(leaf_0, path_0) == nftrec.root; // step 4
    let leaf_1_ok = true;
    if !leaf_1.is_empty() { // step 5
        leaf_1_ok = compute_root(leaf_1, path_1) == nftrec.root;
    }
    if leaf_1.is_empty() { // step 6
        leaf_1 = merkle_leaf::new(message.token_id, message.address2);
        // (message.address2 is receiver for transfer operation)
    }
    let token_ok = leaf_0.token_id == message.token_id; // step 7
    let lock_ok = leaf_0.is_locked == false; // step 8
    let xfer_ok = // step 9
        leaf_0.decrement(message.amount) &&
        leaf_1.increment(message.amount);
    let new_root_ok = // step 10
        compute_root(leaf_0, path_0) == new_root &&
        compute_root(leaf_1, path_1) == new_root;
    return
        sig_ok &&
        op_ok &&
        caller_ok &&
        leaf_0_ok &&
        leaf_1_ok &&
        token_ok &&
        lock_ok &&
        xfer_ok &&
        new_root_ok;
}

////////////////////////////////////////////////////////////////////////////////

// Check the conditions of the approve operation.
// The steps indicated in the comments are the ones in ARC-721.
// Should message.address1 be checked against leaf.owner?
// Should we check that the leaf is not locked?
function check_approve(record: record,
                       message: message,
                       signature: signature,
                       path: merkle_path,
                       leaf: merkle_leaf,
                       new_root: merkle_root) -> bool {
    let nftrec = nft_record::deserialize(record);
    let sig_ok = message.verify_signature(signature); // step 1
    let op_ok = message.opcode == opcode_approve; // step 2
    let caller_ok = // step 3
        message.caller == nftrec.owner ||
        message.caller == leaf.owner;
    let leaf_ok = compute_root(leaf, path) == nftrec.root; // step 4
    let token_ok = leaf.token_id == message.token_id; // step 5
    leaf.operator = message.address2; // step 6
    let new_root_ok = compute_root(leaf, path) == new_root; // step 7
    return
        sig_ok &&
        op_ok &&
        caller_ok &&
        leaf_ok &&
        token_ok &&
        new_root_ok;
}

////////////////////////////////////////////////////////////////////////////////

// Check the conditions of the lock operation.
// The steps indicated in the comments are the ones in ARC-721.
// Should message.address1 be checked against leaf.owner?
function check_lock(record: record,
                    message: message,
                    signature: signature,
                    path: merkle_path,
                    leaf: merkle_leaf,
                    new_root: merkle_root) -> bool {
    let nftrec = nft_record::deserialize(record);
    let sig_ok = message.verify_signature(signature); // step 1
    let op_ok = message.opcode == opcode_lock; // step 2
    let caller_ok = message.caller == nftrec.owner; // step 3
    let leaf_ok = compute_root(leaf, path) == nftrec.root; // step 4
    let token_ok = leaf.token_id == message.token_id; // step 5
    let lock_ok = leaf.is_locked == false; // step 6
    leaf.is_locked = true; // step 7
    let new_root_ok = compute_root(leaf, path) == new_root; // step 8
    return
        sig_ok &&
        op_ok &&
        caller_ok &&
        leaf_ok &&
        token_ok &&
        lock_ok &&
        new_root_ok;
}

////////////////////////////////////////////////////////////////////////////////

// Check the conditions of the unlock operation.
// The steps indicated in the comments are the ones in ARC-721.
// Should message.address1 be checked against leaf.owner?
function check_unlock(record: record,
                      message: message,
                      signature: signature,
                      path: merkle_path,
                      leaf: merkle_leaf,
                      new_root: merkle_root) -> bool {
    let nftrec = nft_record::deserialize(record);
    let sig_ok = message.verify_signature(signature); // step 1
    let op_ok = message.opcode == opcode_unlock; // step 2
    let caller_ok = message.caller == nftrec.owner; // step 3
    let leaf_ok = compute_root(leaf, path) == nftrec.root; // step 4
    let token_ok = leaf.token_id == message.token_id; // step 5
    let lock_ok = leaf.is_locked == true; // step 6
    leaf.is_locked = false; // step 7
    let new_root_ok = compute_root(leaf, path) == new_root; // step 8
    return
        sig_ok &&
        op_ok &&
        caller_ok &&
        leaf_ok &&
        token_ok &&
        lock_ok &&
        new_root_ok;
}

////////////////////////////////////////////////////////////////////////////////

// Check the conditions of the burn operation.
// The steps indicated in the comments are the ones in ARC-721.
// Should message.address1 be checked against leaf.owner?
function check_burn(record: record,
                    message: message,
                    signature: signature,
                    path: merkle_path,
                    leaf: merkle_leaf,
                    new_root: merkle_root) -> bool {
    let nftrec = nft_record::deserialize(record);
    let sig_ok = message.verify_signature(signature); // step 1
    let op_ok = message.opcode == opcode_burn; // step 2
    let caller_ok = message.caller == nftrec.owner; // step 3
    let leaf_ok = compute_root(leaf, path) == nftrec.root; // step 4
    let token_ok = leaf.token_id == message.token_id; // step 5
    let lock_ok = leaf.is_locked == false; // step 6
    let dec_ok = leaf.decrement(message.amount); // step 7
    let new_root_ok = compute_root(leaf, path) == new_root; // step 8
    return
        sig_ok &&
        op_ok &&
        caller_ok &&
        leaf_ok &&
        token_ok &&
        lock_ok &&
        dec_ok &&
        new_root_ok;
}

////////////////////////////////////////////////////////////////////////////////

// In order to consume and produce records,
// we need Leo functions that take and return records.
// When the initial prototype of the new transaction model is implemented,
// the Leo CLI will generate transactions that consume and produce records.
// According to the initial design of the transaction model,
// transitions are calculated via Leo functions annotated with @transition,
// and from those transactions with single transitions are created.
// (NFT batch operations are not represented here yet.)
// Since the @transition annotation is not supported yet,
// we put it in comments for now.

// The trans_<op> functions below take
// the same inputs as the check_<op> functions above,
// but they return different outputs:
// each returns a boolean, which says if the operation is successful,
// and a new record, which is significant only if the boolean is true.
// This assumes that when the Leo CLI calls the Leo transition functions,
// it creates transitions and transactions only if the boolean is true.
// It would be more elegant to have these functions return a record option,
// but option types are not supported in Leo yet.

////////////////////////////////////////////////////////////////////////////////

// Calculate a new record from an old record and a new Merkle root.
// This is the new record produced by a transition:
// the owner is the same as the old record;
// the payload contains the new Merkle root.
function new_record(record: record, new_root: merkle_root) -> record {
    return nft_record::new(record.owner, new_root).serialize();
}

////////////////////////////////////////////////////////////////////////////////

// Transition for the mint operation.
// @transition
function trans_mint(record: record,
                    message: message,
                    signature: signature,
                    path: merkle_path,
                    leaf: merkle_leaf,
                    new_root: merkle_root) -> (bool, record) {
    return (check_mint(record, message, signature, path, leaf, new_root),
            new_record(record, new_root));
}

////////////////////////////////////////////////////////////////////////////////

// Transition for the transfer operation.
// @transition
function trans_transfer(record: record,
                        message: message,
                        signature: signature,
                        path_0: merkle_path,
                        path_1: merkle_path,
                        leaf_0: merkle_leaf,
                        leaf_1: merkle_leaf,
                        new_root: merkle_root) -> (bool, record) {
    return (check_transfer(record, message, signature,
                           path_0, path_1, leaf_0, leaf_1, new_root),
            new_record(record, new_root));
}

////////////////////////////////////////////////////////////////////////////////

// Transition for the approve operation.
// @transition
function trans_approve(record: record,
                       message: message,
                       signature: signature,
                       path: merkle_path,
                       leaf: merkle_leaf,
                       new_root: merkle_root) -> (bool, record) {
    return (check_approve(record, message, signature, path, leaf, new_root),
            new_record(record, new_root));
}

////////////////////////////////////////////////////////////////////////////////

// Transition for the lock operation.
// @transition
function trans_lock(record: record,
                    message: message,
                    signature: signature,
                    path: merkle_path,
                    leaf: merkle_leaf,
                    new_root: merkle_root) -> (bool, record) {
    return (check_lock(record, message, signature, path, leaf, new_root),
            new_record(record, new_root));
}

////////////////////////////////////////////////////////////////////////////////

// Transition for the unlock operation.
// @transition
function trans_unlock(record: record,
                      message: message,
                      signature: signature,
                      path: merkle_path,
                      leaf: merkle_leaf,
                      new_root: merkle_root) -> (bool, record) {
    return (check_unlock(record, message, signature, path, leaf, new_root),
            new_record(record, new_root));
}

////////////////////////////////////////////////////////////////////////////////

// Transition for the burn operation.
// @transition
function trans_burn(record: record,
                    message: message,
                    signature: signature,
                    path: merkle_path,
                    leaf: merkle_leaf,
                    new_root: merkle_root) -> (bool, record) {
    return (check_burn(record, message, signature, path, leaf, new_root),
            new_record(record, new_root));
}

////////////////////////////////////////////////////////////////////////////////

// Since the initial prototype transition model is not yet available,
// we dispatch from main() to the transition funcitons above.
// This way, at least we ensure that the code above is compiled to R1CS.
// Since the Leo input file does not seem to support circuit values,
// we take as inputs just an opcode
// and a byte that we use to generate non-constant inputs for the operations.
// Then we return a byte from the resulting record, along with the boolean.
function main(opcode: u8, x: u8) -> (bool, u8) {
    // the exact values here do not matter;
    // it is just so that things are not optimized away
    // and all the code above is compiled to R1CS:
    let address1 =
        aleo1fuge6ah8c9custvmlju5t30gk8p8lar5x36jlfa2glhgy9n0fuxsreeh2c;
    let address2 =
        aleo1qnr4dkkvkgfqph0vzc3y6z2eu975wnpz2925ntjccd5cfqxtyu8sta57j8;
    let record = record {
        owner: address1,
        payload: [...[x; 32], ...[0; 96]]
    };
    let message = message {
        opcode: opcode,
        caller: address1,
        token_id: [x; 32],
        address1: address1,
        address2: address2,
        amount: x < 100 ? 10 : 20
    };
    let signature = [x; 64];
    let path = [merkle_path_element { hash: [x; 32], left: true }; 16];
    let path1 = [merkle_path_element { hash: [x; 32], left: false }; 16];
    let leaf = merkle_leaf::new([x; 32], address1);
    let leaf1 = merkle_leaf::new([x; 32], address2);
    let new_root = [x; 32];
    if opcode == opcode_mint {
        let (ok, rec) = trans_mint(record, message, signature,
                                   path, leaf, new_root);
        return (ok, rec.payload[0]);
    } else if opcode == opcode_transfer {
        let (ok, rec) = trans_transfer(record, message, signature,
                                       path, path1, leaf, leaf1, new_root);
        return (ok, rec.payload[0]);
    } else if opcode == opcode_approve {
        let (ok, rec) = trans_approve(record, message, signature,
                                      path, leaf, new_root);
        return (ok, rec.payload[0]);
    } else if opcode == opcode_lock {
        let (ok, rec) = trans_lock(record, message, signature,
                                   path, leaf, new_root);
        return (ok, rec.payload[0]);
    } else if opcode == opcode_unlock {
        let (ok, rec) = trans_unlock(record, message, signature,
                                     path, leaf, new_root);
        return (ok, rec.payload[0]);
    } else if opcode == opcode_burn {
        let (ok, rec) = trans_burn(record, message, signature,
                                   path, leaf, new_root);
        return (ok, rec.payload[0]);
    } else {
        return (false, 0);
    }
}

////////////////////////////////////////////////////////////////////////////////

// This program currently does not compile because
// to_bytes_le method is not implemented for addresses.
