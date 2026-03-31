// gold_token.aleo — private gold token implementing the TokenStandard interface.
//
// The Token record carries an extra `purity` field (karat value, 1–24) beyond
// the minimum fields required by TokenStandard.  When gold_token.aleo is
// called via dynamic dispatch, the caller receives the token as `dyn record`
// and never needs to know about `purity` at compile time.
interface TokenStandard {
    record Token {
        owner: address,
        amount: u64,
        ..  // implementors may add extra fields beyond these
    }
    fn mint(owner: address, amount: u64) -> Token;
    fn transfer(token: dyn record, to: address) -> dyn record;
    fn balance_of(token: dyn record) -> u64;
}

program gold_token.aleo : TokenStandard {
    // Token carries purity (karat value) alongside the standard fields.
    // This extra field is invisible to the router at compile time but remains
    // accessible via `dyn record` field access inside this program.
    record Token {
        owner: address,
        amount: u64,   // milligrams
        purity: u64,   // karat value: 1 (lowest) to 24 (pure gold)
    }

    // Creates a Token at maximum purity (24-karat).
    // This satisfies the interface's `mint` requirement with a sensible default.
    fn mint(owner: address, amount: u64) -> Token {
        return Token { owner, amount, purity: 24u64 };
    }

    // Creates a Token with a custom purity level.
    // This is a program-specific function — not required by the interface.
    fn mint_custom(owner: address, amount: u64, purity: u64) -> Token {
        assert(purity >= 1u64 && purity <= 24u64);
        return Token { owner, amount, purity };
    }

    // Transfers the token to a new owner.
    //
    // `token` arrives as `dyn record` because dynamic calls always erase the
    // concrete type.  We read the fields we care about — including the
    // program-specific `purity` field — rebuild the record under the new
    // owner, then cast back to `dyn record` for the return value.
    fn transfer(token: dyn record, to: address) -> dyn record {
        let amount: u64 = token.amount;
        let purity: u64 = token.purity;  // dyn record field access — fails at runtime if missing
        let new_token: Token = Token { owner: to, amount, purity };
        return new_token as dyn record;  // explicit cast: static record → dyn record
    }

    // Returns the token's amount without needing to know its full structure.
    fn balance_of(token: dyn record) -> u64 {
        return token.amount;
    }

    @noupgrade
    constructor() {}
}
