// silver_token.aleo — private silver token implementing the TokenStandard interface.
//
// Its Token record adds a `grade` field (quality tier: 0 = industrial, 3 = sterling)
// instead of a purity field.  Despite a different extra field from GoldToken,
// silver_token.aleo is fully interchangeable through TokenStandard: the router
// treats both uniformly without knowing either concrete record structure.
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

program silver_token.aleo : TokenStandard {
    // Token carries a `grade` field instead of purity — a different extra field
    // than GoldToken, demonstrating that `..` allows each implementor to diverge.
    record Token {
        owner: address,
        amount: u64,   // milligrams
        grade: u64,    // quality tier: 0 (industrial) to 3 (sterling)
    }

    // Creates a Token at sterling grade (highest quality).
    fn mint(owner: address, amount: u64) -> Token {
        return Token { owner, amount, grade: 3u64 };
    }

    // Creates a Token with a custom grade.
    fn mint_custom(owner: address, amount: u64, grade: u64) -> Token {
        assert(grade <= 3u64);
        return Token { owner, amount, grade };
    }

    // Transfers the token to a new owner.
    // Reads `grade` from the incoming `dyn record` and carries it to the new token.
    fn transfer(token: dyn record, to: address) -> dyn record {
        let amount: u64 = token.amount;
        let grade: u64 = token.grade;
        let new_token: Token = Token { owner: to, amount, grade };
        return new_token as dyn record;
    }

    fn balance_of(token: dyn record) -> u64 {
        return token.amount;
    }

    @noupgrade
    constructor() {}
}
