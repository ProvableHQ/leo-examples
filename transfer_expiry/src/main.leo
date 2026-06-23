// The 'transfer_public_expiry' program.
import credits.aleo;

program transfer_public_expiry.aleo {

    // Struct to hold address and nonce for hashing
    struct NonceKey {
        sender: address,
        nonce: u64,
    }

    // Mapping to store used nonces for each sender address
    // Key is the NonceKey struct containing address and nonce
    mapping used_nonces: NonceKey => bool;

    // Default constructor which doesn't allow for program upgrades.
    @noupgrade
    async constructor() {}

    // Wrapper around credits.aleo::transfer_public with an expiry and nonce validation.
    async transition transfer_public_with_expiry(
        public to: address,
        public amount: u64,
        public expiry_block_height: u32,
        public nonce: u64
    ) -> Future {
        // Get the sender's address before entering async block
        let sender: address = self.caller;
        
        // Call the original transfer_public function from credits.aleo
        let f1 = credits.aleo/transfer_public(to, amount);

        let f2: Future = async {
            // Create a NonceKey struct with the sender address and nonce
            let nonce_key: NonceKey = NonceKey {
                sender: sender,
                nonce: nonce,
            };
            
            // Check if the nonce has already been used for this sender
            let is_used: bool = used_nonces.get(nonce_key);
            assert(!is_used);
            
            // Store the nonce as used for this sender
            used_nonces.set(nonce_key, true);
            
            // Check if current block height is below the expiry block height
            let current_block_height: u32 = block.height;
            assert(current_block_height < expiry_block_height);
            f1.await();
        };

        return f2;
    }
}

