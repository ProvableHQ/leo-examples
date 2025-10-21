// The 'transfer_public_expiry' program.
import credits.aleo;

program transfer_public_expiry.aleo {

    // Default constructor which doesn't allow for program upgrades.
    @noupgrade
    async constructor() {}

    // Wrapper around credits.aleo::transfer_public with an expiry.
    async transition transfer_public_with_expiry(
        public to: address,
        public amount: u64,
        public expiry_block_height: u32
    ) -> Future {
        // Call the original transfer_public function from credits.aleo
        let f1 = credits.aleo/transfer_public(to, amount);

        let f2: Future = async {
            // Check if current block height is below the expiry block height
            let current_block_height: u32 = block.height;
            assert(current_block_height < expiry_block_height);
            f1.await();
        };

        return f2;
    }
}

