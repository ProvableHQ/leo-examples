// An instruction to execute on the calculator.
// Note: Negative values indicate a regsiter. 
//   There are 32 valid registers. (-1, ..., -32)
struct Instruction {
  opcode: u8,
  // An operand.
  op0: i64,
  // An operand.
  op1: i64,
  // A destination register.
  d0: i64,
}

// Creates an instruction.
inline init(opcode: u8, op0: i64, op1: i64, d0: i64) -> Instruction {
  assert(opcodes::opcode_is_valid(opcode));
  assert(operand_is_valid(op0));
  assert(operand_is_valid(op1));
  assert(destination_is_valid(d0));
  return Instruction {
    opcode,
    op0,
    op1,
    d0
  };
}

// Createa a `NOOP` instruction.
inline noop() -> Instruction {
  return init(opcodes::NOOP, 0, 0, 0);
}

// Creates a `ADD` instruction.
inline add(r0: i64, r1: i64, d0: i64) -> Instruction {
  return init(opcodes::ADD, r0, r1, d0);
}

// Creates a `SUB` instruction.
inline sub(r0: i64, r1: i64, d0: i64) -> Instruction {
  return init(opcodes::SUB, r0, r1, d0);
}

// Creates a `MUL` instruction.
inline mul(r0: i64, r1: i64, d0: i64) -> Instruction {
  return init(opcodes::MUL, r0, r1, d0);
}

// Creates a `DIV` instruction.
inline div(r0: i64, r1: i64, d0: i64) -> Instruction {
  return init(opcodes::DIV, r0, r1, d0);
}


// Returns whether an operand is valid.
inline operand_is_valid(op: i64) -> bool {
  return op >= -32i64;
}

// Returns whether a destination register is valid.
inline destination_is_valid(d: i64) -> bool {
  return d < 0 && d >= -32i64;
}





