// A register file.
struct Registers::[N: u32] {
  r: [u32; N],
}

// Initializes a register file.
inline init::[N: u32]() -> Registers::[N] {
  return Registers::[N] {
    r: [0u32; N],
  };
}

// Loads an operand. 
inline load::[N: u32](registers: Registers::[N], op: i64) -> u32 {
  // Initialize the result.
  let result = op;
  // Iterate through the registers and check for a match.
  for i in 0u32..N {
    let id: i64 = index_to_id(i);
    if op == id {
      result = registers.r[i] as i64;
    }
  }
  // Cast the result to a `u32`` and return it.
  return (result as u32);
}

// Stores a value into a register.
inline store::[N: u32](registers: Registers::[N], d: i64, v: u32) -> Registers::[N] {
  // Get the register index.
  let index = id_to_index::[N](d);
  // Iterate through the registers and set the appropriate one.
  for i in 0u32..N {
    if index == i {
      registers.r[i] = v;
    }
  }
  // Return the updated registers.
  return registers;
}


// Convert a register index into its ID.
inline index_to_id(i: u32) -> i64 {
  return -(i as i64 + 1);
}

// Convert a register ID into an index, checking for validity.
inline id_to_index::[N: u32](id: i64) -> u32 {
  assert(id < 0 && id >= -(N as i64));
  return (id + 1) as u32;
}
