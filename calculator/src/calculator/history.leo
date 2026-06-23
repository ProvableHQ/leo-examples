// A finite history of past instructions.
struct History::[N: u32] {
    // The total number of instructions.
    total: u32,
    // The head of the buffer.
    head: u32,
    // The entries.
    entries: [instruction::Instruction; N],
}

// A transcript of the history in order from newest to oldest.
struct Transcript::[N: u32] {
    // The total number of instructions.
    total: u32,
    // The entries in order.
    entries: [instruction::Instruction; N]
}

// Initializes a `History` object.
inline init::[N: u32]() -> History::[N] {
  return History::[N] {
    total: 0,
    head: 0,
    entries: [instruction::noop(); N],
  };
}

// Adds an instruction to the history.
inline push::[N: u32](history: History::[N], instruction: instruction::Instruction) -> History::[N] {
  // Add the instruction.
  history.entries[history.head] = instruction;
  // Increment the total.
  history.total += 1;
  // Increment the head.
  history.head = history.head.add_wrapped(1) % N;
  // Return the updated history.
  return history;
}

// Returns the transcript.
inline transcript::[N: u32](history: History::[N]) -> Transcript::[N] {
  // Initialize dummy entries.
  let entries = [instruction::noop(); N];
  // Update the entries.
  for i in 0u32..N {
    entries[i] = history.entries[i.sub_wrapped(1) % N];
  }
  // Return the transcript.
  return Transcript::[N] {
    total: history.total,
    entries
  };

}

