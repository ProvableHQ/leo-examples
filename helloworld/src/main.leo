program helloworld.aleo {
    // The 'helloworld' main function.
    fn main(public a: u32, b: u32) -> u32 {
        return a + b;
    }

    // The constructor is configured to prevent upgrades.
    @noupgrade
    async constructor() {}
}

