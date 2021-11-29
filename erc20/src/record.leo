circuit Record {
    owner: address;
    // TODO: Does snarkVM enforce that values in transitions/transactions are valid?
    // Such checks are essential, if users are allowed to read/manipulate records in Leo programs.
    value: u32; //AleoAmount
    payload: [u8; 128];
    // TODO: How are the below types represented in Leo?
    // Do we need Leo programs to reason about view keys and ciphertext?
    // How should program_id's be used?
    program_id: ProgramID;
    record_view_key: RecordViewKey;
    record_ciphertext: RecordCiphertext;
}



