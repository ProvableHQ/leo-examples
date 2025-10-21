// The 'test_transfer_public_expiry' test program.
import transfer_public_expiry.aleo;
program test_transfer_public_expiry.aleo {
    @test
    transition test_expiry() {
        // Test the transfer_public_with_expiry function
        // This would normally require proper setup with credits, but demonstrates the interface
        let to: address = aleo1kanvv2cs88dpguwz5yrv890zz89rmycyk7qe6q4qm7vnz30flyzs56zae8;
        let amount: u64 = 1000u64;
        let expiry_block_height: u32 = 1000000u32;
        
        // Call the wrapper function
        transfer_public_expiry.aleo/transfer_public_with_expiry(to, amount, expiry_block_height);
    }
}
