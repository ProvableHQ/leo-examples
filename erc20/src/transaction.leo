// snarkVM source code for transactions.

//pub struct Transaction<N: Network> {
//    /// The ID of this transaction.
//    transaction_id: N::TransactionID,
//    /// The ID of the inner circuit used to execute each transition.
//    inner_circuit_id: N::InnerCircuitID,
//    /// The ledger root used to prove inclusion of ledger-consumed records.
//    ledger_root: N::LedgerRoot,
//    /// The state transition.
//    transitions: Vec<Transition<N>>,
//    /// The events emitted from this transaction.
//    events: Vec<Event<N>>,
//}

// It doesn't seem like users need Transaction data to write Leo programs. Instead it should
// be the job of the CLI tool to construct it after analyzing the code (annotations, datatypes).