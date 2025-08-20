// The 'calculator' program.
program calculator.aleo {
    @noupgrade
    async constructor() {}

    const SIZE: u32 = 8;

    transition init() -> calculator::Calculator::[SIZE] {
      return calculator::init::[SIZE]();
    }

    transition execute(
      c: calculator::Calculator::[SIZE],
      instructions: [calculator::history::instruction::Instruction; SIZE],
    ) -> calculator::Calculator::[SIZE] {
      return calculator::execute::[SIZE](c, instructions);
    }

    transition transcript(
      c: calculator::Calculator::[SIZE]
    ) -> calculator::history::Transcript::[2 * SIZE] {
      return calculator::transcript::[SIZE](c);
    }

}
