// The 'timelock_example' program.
program timelock_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}

    async constructor() {
        if self.edition > 0u16 {
            assert(block.height >= 1300u32);
        }
    }
}
