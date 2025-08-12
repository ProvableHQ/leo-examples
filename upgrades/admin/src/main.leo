// The 'admin_example' program.
program admin_example.aleo {
     @admin(address="aleo1tm8mt8r96fnya58zz2ws43ud7e4q2guktfujj8ye6zzfrstjpyysakpmdu")
     async constructor() {}

    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}
}
