// The 'timelock_example' program.
program timelock_example.aleo {
    @custom
    constructor() {
        if std::ctx::edition() > 0u16 {
            assert(std::ctx::block_height() >= 1300u32);
        }
    }

    fn main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // fn foo() {}
}
