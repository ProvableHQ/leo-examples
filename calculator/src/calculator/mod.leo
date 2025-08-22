// A programmable calculator.
struct Calculator::[N: u32] {
  // The registers.
  registers: registers::Registers::[N],
  // The history.
  // TODO: Make history longer.
  history: history::History::[2 * N],
}

// Initialize the calculator.
inline init::[N: u32]() -> Calculator::[N] {
  return Calculator::[N] {
    registers: registers::init::[N](),
    history: history::init::[2 * N]()
  };
}

// Executes a sequence of instructions.
inline execute::[N: u32](
  c: Calculator::[N],
  instructions: [history::instruction::Instruction; N]
) -> Calculator::[N] {
  for i in 0u32..N {
    c = exec::[N](c, instructions[i]);
  }
  return c;
}

// Returns a transcript of the history.
inline transcript::[N: u32](c: Calculator::[N]) -> history::Transcript::[2 * N] {
  return history::transcript::[2 * N](c.history);
}

// Executes a single instruction.
inline exec::[N: u32](
  c: Calculator::[N],
  i: history::instruction::Instruction,
) -> Calculator::[N] {
  // Handle NOOP.
  if i.opcode == history::instruction::opcodes::NOOP {
    return c;
  }

  // Load the operands.
  let op0 = registers::load::[N](c.registers, i.op0);
  let op1 = registers::load::[N](c.registers, i.op1);

  // Evaluate the operands.
  let result = 0u32;
  if i.opcode == history::instruction::opcodes::ADD {
    result = math::add(op0, op1);
  } else if i.opcode == history::instruction::opcodes::SUB {
    result = math::sub(op0, op1);
  } else if i.opcode == history::instruction::opcodes::MUL {
    result = math::mul(op0, op1);
  } else if i.opcode == history::instruction::opcodes::DIV {
    result = math::div(op0, op1);
  } else {
    assert(false);
  }

  // Store the result.
  c.registers = registers::store::[N](c.registers, i.d0, result);

  // Return the updated calculator.
  return c;
}
