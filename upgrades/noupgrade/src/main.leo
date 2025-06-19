// The 'noupgrade_example' program.
program noupgrade_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}

    // This is the constructor for the program.
    // It is called when the program is deployed or upgraded.
    // It is currently configured to **prevent** upgrades.
    // For more information, please refer to the documentation: <TODO>.
    async constructor() {
        assert_eq(self.edition, 0u16);
    }
}
