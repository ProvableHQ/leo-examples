// Placedholder, just to get the code to compile.
circuit ProgramID {
   id: u64 
}

// Placeholder, just to get the code to compile.
circuit RecordViewKey {
    key: [u8; 32];
}


circuit Record {
    owner: address;
    // TODO: Does snarkVM enforce that values in transitions/transactions are valid?
    // Such checks are essential, if users are allowed to read/manipulate records in Leo programs.
    value: u32; //AleoAmount //TODO: Aleo unit keyword (like gwei in Solidity)
    payload: [u8; 128];
    // TODO: How are the below types represented in Leo?
    // Do we need Leo programs to reason about view keys and ciphertext?
    // How should program_id's be used?
    program_id: ProgramID;
    record_view_key: RecordViewKey;
    // record_ciphertext: RecordCiphertext; // Not needed.
}




