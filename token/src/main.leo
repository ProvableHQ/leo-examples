program token.aleo {
    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    record Token {
        // The token owner.
        owner: address,
        // The token amount.
        amount: u64,
    }

    /* Mint */

    // The function `mint_public` issues the specified token amount for the token receiver publicly on the network.
    fn mint_public(public receiver: address, public amount: u64) -> Final {
        // Mint the tokens publicly by invoking the computation on-chain.
        return final {
            // Increments `account[receiver]` by `amount`.
            // If `account[receiver]` does not exist, it will be created.
            // If `account[receiver] + amount` overflows, `mint_public` is reverted.
            let current_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
            Mapping::set(account, receiver, current_amount + amount);
        };
    }

    // The function `mint_private` initializes a new record with the specified amount of tokens for the receiver.
    fn mint_private(receiver: address, amount: u64) -> Token {
        return Token {
            owner: receiver,
            amount: amount,
        };
    }

    /* Transfer */
    fn transfer_public(public receiver: address, public amount: u64) -> Final {
        // Transfer the tokens publicly, by invoking the computation on-chain.
        let caller = std::ctx::caller();
        return final {
            // Decrements `account[sender]` by `amount`.
            // If `account[sender]` does not exist, it will be created.
            // If `account[sender] - amount` underflows, `transfer_public` is reverted.
            let sender_amount: u64 = Mapping::get_or_use(account, caller, 0u64);
            Mapping::set(account, caller, sender_amount - amount);
            // Increments `account[receiver]` by `amount`.
            // If `account[receiver]` does not exist, it will be created.
            // If `account[receiver] + amount` overflows, `transfer_public` is reverted.
            let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
            Mapping::set(account, receiver, receiver_amount + amount);
        };
    }

    // The function `transfer_private` sends the specified token amount to the token receiver from the specified token record.
    fn transfer_private(sender: Token, receiver: address, amount: u64) -> (Token, Token) {
        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail if an overflow occurs.
        // `difference` holds the change amount to be returned to sender.
        let difference: u64 = sender.amount - amount;

        // Produce a token record with the change amount for the sender.
        let remaining: Token = Token {
            owner: sender.owner,
            amount: difference,
        };

        // Produce a token record for the specified receiver.
        let transferred: Token = Token {
            owner: receiver,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }

    // The function `transfer_private_to_public` turns a specified token amount from a token record into public tokens for the specified receiver.
    // This function preserves privacy for the sender's record, however it publicly reveals the token receiver and the token amount.
    fn transfer_private_to_public(sender: Token, public receiver: address, public amount: u64) -> (Token, Final) {
        // Checks the given token record has a sufficient token amount.
        // This `sub` operation is safe, and the proof will fail if an underflow occurs.
        // `difference` holds the change amount for the caller.
        let difference: u64 = sender.amount - amount;

        // Produces a token record with the change amount for the caller.
        let remaining: Token = Token {
            owner: sender.owner,
            amount: difference,
        };

        // Output the sender's change record.
        // Increment the token amount publicly for the token receiver.
        return (remaining, final {
            // Increments `account[receiver]` by `amount`.
            // If `account[receiver]` does not exist, it will be created.
            // If `account[receiver] + amount` overflows, `transfer_private_to_public` is reverted.
            let current_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
            Mapping::set(account, receiver, current_amount + amount);
        });
    }

    // The function `transfer_public_to_private` turns a specified token amount from `account` into a token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    fn transfer_public_to_private(public receiver: address, public amount: u64) -> (Token, Final) {
        // Produces a token record for the token receiver.
        let transferred: Token = Token {
            owner: receiver,
            amount: amount,
        };
        let caller = std::ctx::caller();

        // Output the receiver's record.
        // Decrement the token amount of the caller publicly.
        return (transferred, final {
            // Decrements `account[sender]` by `amount`.
            // If `account[sender]` does not exist, it will be created.
            // If `account[sender] - amount` underflows, `transfer_public_to_private` is reverted.
            let current_amount: u64 = Mapping::get_or_use(account, caller, 0u64);
            Mapping::set(account, caller, current_amount - amount);
        });
    }

    // The constructor is configured to prevent upgrades.
    @noupgrade
    constructor() {}
}
