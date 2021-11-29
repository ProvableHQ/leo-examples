// snarkVM source code for Transitions

//pub struct Transition<N: Network> {
//    /// The ID of this transition.
//    transition_id: N::TransitionID,
//    /// The serial numbers of the input records.
//    serial_numbers: Vec<N::SerialNumber>,
//    /// The commitments of the output records.
//    commitments: Vec<N::Commitment>,
//    /// The ciphertexts of the output records.
//    ciphertexts: Vec<RecordCiphertext<N>>,
//    /// A value balance is the difference between the input and output record values.
//    value_balance: AleoAmount,
//    /// The zero-knowledge proof attesting to the validity of this transition.
//    proof: N::OuterProof,
//}

// It doesn't seem like users need transition data to write Leo programs. Instead it should
// be the job of the CLI tool to construct it after analyzing the code (annotations, datatypes).