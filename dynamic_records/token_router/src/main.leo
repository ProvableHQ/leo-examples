// token_router.aleo routes token operations to any TokenStandard-compliant program.
//
// The router never knows the concrete field layout of GoldToken or SilverToken.
// All record I/O uses `dyn record`, letting the router handle any compliant token —
// including programs deployed after token_router.aleo itself.
//
// Dynamic call syntax used here:
//   TokenStandard@(token_program)/transfer(token, to)
//   ├─ TokenStandard      → interface declared in this file
//   ├─ @(token_program)   → runtime-resolved target (an `identifier` value)
//   └─ /transfer          → function to invoke on that program
interface TokenStandard {
    record Token {
        owner: address,
        amount: u64,
        ..
    }
    fn mint(owner: address, amount: u64) -> Token;
    fn transfer(token: dyn record, to: address) -> dyn record;
    fn balance_of(token: dyn record) -> u64;
}

program token_router.aleo {
    // Routes a transfer to any TokenStandard-compliant program at runtime.
    //
    // Case A (dyn record in, dyn record out): the caller already holds a `dyn record`
    // and passes it directly.  No cast is needed.  The return type is always
    // `dyn record` regardless of what the interface signature declares.
    fn route_transfer(
        token_program: identifier,
        token: dyn record,
        to: address,
    ) -> dyn record {
        return TokenStandard@(token_program)/transfer(token, to);
    }

    // Reads the balance from any token without knowing its concrete type.
    //
    // The `dyn record` field access (`.amount`) happens inside `balance_of` on
    // the target program — the router itself never touches record fields here.
    fn read_balance(token_program: identifier, token: dyn record) -> u64 {
        return TokenStandard@(token_program)/balance_of(token);
    }

    // Mints a token and immediately routes it to a recipient — all in one call.
    //
    // `mint` returns a concrete Token on the target program; through dynamic
    // dispatch the router receives it as `dyn record` and forwards it directly
    // to `transfer`.  Two dynamic calls, zero compile-time knowledge of the
    // underlying record type.
    fn demo_transfer(
        token_program: identifier,
        owner: address,
        amount: u64,
        to: address,
    ) -> dyn record {
        let token: dyn record = TokenStandard@(token_program)/mint(owner, amount);
        return TokenStandard@(token_program)/transfer(token, to);
    }

    // Compares gold and silver balances using identifier literals.
    //
    // The targets 'gold_token' and 'silver_token' are pinned at compile time
    // (and verified at deploy time) while still going through the dynamic-
    // dispatch path at the AVM level.  Returns true if the gold token holds
    // a larger amount than the silver token.
    fn gold_beats_silver(
        gold_tok: dyn record,
        silver_tok: dyn record,
    ) -> bool {
        let gold_bal: u64 = TokenStandard@('gold_token')/balance_of(gold_tok);
        let silver_bal: u64 = TokenStandard@('silver_token')/balance_of(silver_tok);
        return gold_bal > silver_bal;
    }

    // Compares balances across any two token programs resolved at runtime.
    //
    // `prog_a` and `prog_b` can be the same program or different ones —
    // the router treats them uniformly.
    fn has_more(
        prog_a: identifier,
        tok_a: dyn record,
        prog_b: identifier,
        tok_b: dyn record,
    ) -> bool {
        let bal_a: u64 = TokenStandard@(prog_a)/balance_of(tok_a);
        let bal_b: u64 = TokenStandard@(prog_b)/balance_of(tok_b);
        return bal_a > bal_b;
    }

    @noupgrade
    constructor() {}
}
