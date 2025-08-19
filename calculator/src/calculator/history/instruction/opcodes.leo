// NOOP
const NOOP: u8 = 0;

// ADD
const ADD: u8 = 1;

// SUB
const SUB: u8 = 2;

// MUL
const MUL: u8 = 3;

// DIV
const DIV: u8 = 4;

// Returns whether an opcode is valid.
inline opcode_is_valid(opcode: u8) -> bool {
  return opcode == 0u8
      || opcode == 1u8
      || opcode == 2u8
      || opcode == 3u8
      || opcode == 4u8;

}


