import credits.aleo;
program virtual_wallet_pubkey.aleo;

struct TransferAuth:
    selector as u8;
    to_bytes as [u8; 32u32];
    amount as u64;
    nonce as u64;
    expiry as u32;

mapping used_nonces:
    key as u64.public;
    value as boolean.public;

function transfer_public:
    input r0 as [u8; 65u32].public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as u64.public;
    input r4 as u32.public;
    call credits.aleo/transfer_public r1 r2 into r5;
    async transfer_public r4 r3 r1 r2 r0 r5 into r6;
    output r6 as virtual_wallet_pubkey.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as u32.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as [u8; 65u32].public;
    input r5 as credits.aleo/transfer_public.future;
    lt block.height r0 into r6;
    assert.eq r6 true;
    contains used_nonces[r1] into r7;
    not r7 into r8;
    assert.eq r8 true;
    cast r2 into r9 as field;
    serialize.bits.raw r9 (field) into r10 ([boolean; 253u32]);
    cast false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false into r11 as [boolean; 256u32];
    cast r10[0u32] r10[1u32] r10[2u32] r10[3u32] r10[4u32] r10[5u32] r10[6u32] r10[7u32] r10[8u32] r10[9u32] r10[10u32] r10[11u32] r10[12u32] r10[13u32] r10[14u32] r10[15u32] r10[16u32] r10[17u32] r10[18u32] r10[19u32] r10[20u32] r10[21u32] r10[22u32] r10[23u32] r10[24u32] r10[25u32] r10[26u32] r10[27u32] r10[28u32] r10[29u32] r10[30u32] r10[31u32] r10[32u32] r10[33u32] r10[34u32] r10[35u32] r10[36u32] r10[37u32] r10[38u32] r10[39u32] r10[40u32] r10[41u32] r10[42u32] r10[43u32] r10[44u32] r10[45u32] r10[46u32] r10[47u32] r10[48u32] r10[49u32] r10[50u32] r10[51u32] r10[52u32] r10[53u32] r10[54u32] r10[55u32] r10[56u32] r10[57u32] r10[58u32] r10[59u32] r10[60u32] r10[61u32] r10[62u32] r10[63u32] r10[64u32] r10[65u32] r10[66u32] r10[67u32] r10[68u32] r10[69u32] r10[70u32] r10[71u32] r10[72u32] r10[73u32] r10[74u32] r10[75u32] r10[76u32] r10[77u32] r10[78u32] r10[79u32] r10[80u32] r10[81u32] r10[82u32] r10[83u32] r10[84u32] r10[85u32] r10[86u32] r10[87u32] r10[88u32] r10[89u32] r10[90u32] r10[91u32] r10[92u32] r10[93u32] r10[94u32] r10[95u32] r10[96u32] r10[97u32] r10[98u32] r10[99u32] r10[100u32] r10[101u32] r10[102u32] r10[103u32] r10[104u32] r10[105u32] r10[106u32] r10[107u32] r10[108u32] r10[109u32] r10[110u32] r10[111u32] r10[112u32] r10[113u32] r10[114u32] r10[115u32] r10[116u32] r10[117u32] r10[118u32] r10[119u32] r10[120u32] r10[121u32] r10[122u32] r10[123u32] r10[124u32] r10[125u32] r10[126u32] r10[127u32] r10[128u32] r10[129u32] r10[130u32] r10[131u32] r10[132u32] r10[133u32] r10[134u32] r10[135u32] r10[136u32] r10[137u32] r10[138u32] r10[139u32] r10[140u32] r10[141u32] r10[142u32] r10[143u32] r10[144u32] r10[145u32] r10[146u32] r10[147u32] r10[148u32] r10[149u32] r10[150u32] r10[151u32] r10[152u32] r10[153u32] r10[154u32] r10[155u32] r10[156u32] r10[157u32] r10[158u32] r10[159u32] r10[160u32] r10[161u32] r10[162u32] r10[163u32] r10[164u32] r10[165u32] r10[166u32] r10[167u32] r10[168u32] r10[169u32] r10[170u32] r10[171u32] r10[172u32] r10[173u32] r10[174u32] r10[175u32] r10[176u32] r10[177u32] r10[178u32] r10[179u32] r10[180u32] r10[181u32] r10[182u32] r10[183u32] r10[184u32] r10[185u32] r10[186u32] r10[187u32] r10[188u32] r10[189u32] r10[190u32] r10[191u32] r10[192u32] r10[193u32] r10[194u32] r10[195u32] r10[196u32] r10[197u32] r10[198u32] r10[199u32] r10[200u32] r10[201u32] r10[202u32] r10[203u32] r10[204u32] r10[205u32] r10[206u32] r10[207u32] r10[208u32] r10[209u32] r10[210u32] r10[211u32] r10[212u32] r10[213u32] r10[214u32] r10[215u32] r10[216u32] r10[217u32] r10[218u32] r10[219u32] r10[220u32] r10[221u32] r10[222u32] r10[223u32] r10[224u32] r10[225u32] r10[226u32] r10[227u32] r10[228u32] r10[229u32] r10[230u32] r10[231u32] r10[232u32] r10[233u32] r10[234u32] r10[235u32] r10[236u32] r10[237u32] r10[238u32] r10[239u32] r10[240u32] r10[241u32] r10[242u32] r10[243u32] r10[244u32] r10[245u32] r10[246u32] r10[247u32] r10[248u32] r10[249u32] r10[250u32] r10[251u32] r10[252u32] r11[253u32] r11[254u32] r11[255u32] into r12 as [boolean; 256u32];
    deserialize.bits.raw r12 ([boolean; 256u32]) into r13 ([u8; 32u32]);
    cast 3u8 r13 r3 r1 r0 into r14 as TransferAuth;
    cast 2u8 75u8 194u8 163u8 18u8 101u8 21u8 63u8 7u8 231u8 14u8 11u8 171u8 8u8 114u8 78u8 107u8 133u8 226u8 23u8 248u8 205u8 98u8 140u8 235u8 98u8 151u8 66u8 71u8 187u8 73u8 51u8 130u8 into r15 as [u8; 33u32];
    ecdsa.verify.keccak256.raw r4 r15 r14 into r16;
    assert.eq r16 true;
    set true into used_nonces[r1];
    await r5;

function transfer_public_to_private:
    input r0 as [u8; 65u32].public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as u64.public;
    input r4 as u32.public;
    call credits.aleo/transfer_public_to_private r1 r2 into r5 r6;
    async transfer_public_to_private r4 r3 r1 r2 r0 r6 into r7;
    output r5 as credits.aleo/credits.record;
    output r7 as virtual_wallet_pubkey.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as u32.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as [u8; 65u32].public;
    input r5 as credits.aleo/transfer_public_to_private.future;
    lt block.height r0 into r6;
    assert.eq r6 true;
    contains used_nonces[r1] into r7;
    not r7 into r8;
    assert.eq r8 true;
    cast r2 into r9 as field;
    serialize.bits.raw r9 (field) into r10 ([boolean; 253u32]);
    cast false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false into r11 as [boolean; 256u32];
    cast r10[0u32] r10[1u32] r10[2u32] r10[3u32] r10[4u32] r10[5u32] r10[6u32] r10[7u32] r10[8u32] r10[9u32] r10[10u32] r10[11u32] r10[12u32] r10[13u32] r10[14u32] r10[15u32] r10[16u32] r10[17u32] r10[18u32] r10[19u32] r10[20u32] r10[21u32] r10[22u32] r10[23u32] r10[24u32] r10[25u32] r10[26u32] r10[27u32] r10[28u32] r10[29u32] r10[30u32] r10[31u32] r10[32u32] r10[33u32] r10[34u32] r10[35u32] r10[36u32] r10[37u32] r10[38u32] r10[39u32] r10[40u32] r10[41u32] r10[42u32] r10[43u32] r10[44u32] r10[45u32] r10[46u32] r10[47u32] r10[48u32] r10[49u32] r10[50u32] r10[51u32] r10[52u32] r10[53u32] r10[54u32] r10[55u32] r10[56u32] r10[57u32] r10[58u32] r10[59u32] r10[60u32] r10[61u32] r10[62u32] r10[63u32] r10[64u32] r10[65u32] r10[66u32] r10[67u32] r10[68u32] r10[69u32] r10[70u32] r10[71u32] r10[72u32] r10[73u32] r10[74u32] r10[75u32] r10[76u32] r10[77u32] r10[78u32] r10[79u32] r10[80u32] r10[81u32] r10[82u32] r10[83u32] r10[84u32] r10[85u32] r10[86u32] r10[87u32] r10[88u32] r10[89u32] r10[90u32] r10[91u32] r10[92u32] r10[93u32] r10[94u32] r10[95u32] r10[96u32] r10[97u32] r10[98u32] r10[99u32] r10[100u32] r10[101u32] r10[102u32] r10[103u32] r10[104u32] r10[105u32] r10[106u32] r10[107u32] r10[108u32] r10[109u32] r10[110u32] r10[111u32] r10[112u32] r10[113u32] r10[114u32] r10[115u32] r10[116u32] r10[117u32] r10[118u32] r10[119u32] r10[120u32] r10[121u32] r10[122u32] r10[123u32] r10[124u32] r10[125u32] r10[126u32] r10[127u32] r10[128u32] r10[129u32] r10[130u32] r10[131u32] r10[132u32] r10[133u32] r10[134u32] r10[135u32] r10[136u32] r10[137u32] r10[138u32] r10[139u32] r10[140u32] r10[141u32] r10[142u32] r10[143u32] r10[144u32] r10[145u32] r10[146u32] r10[147u32] r10[148u32] r10[149u32] r10[150u32] r10[151u32] r10[152u32] r10[153u32] r10[154u32] r10[155u32] r10[156u32] r10[157u32] r10[158u32] r10[159u32] r10[160u32] r10[161u32] r10[162u32] r10[163u32] r10[164u32] r10[165u32] r10[166u32] r10[167u32] r10[168u32] r10[169u32] r10[170u32] r10[171u32] r10[172u32] r10[173u32] r10[174u32] r10[175u32] r10[176u32] r10[177u32] r10[178u32] r10[179u32] r10[180u32] r10[181u32] r10[182u32] r10[183u32] r10[184u32] r10[185u32] r10[186u32] r10[187u32] r10[188u32] r10[189u32] r10[190u32] r10[191u32] r10[192u32] r10[193u32] r10[194u32] r10[195u32] r10[196u32] r10[197u32] r10[198u32] r10[199u32] r10[200u32] r10[201u32] r10[202u32] r10[203u32] r10[204u32] r10[205u32] r10[206u32] r10[207u32] r10[208u32] r10[209u32] r10[210u32] r10[211u32] r10[212u32] r10[213u32] r10[214u32] r10[215u32] r10[216u32] r10[217u32] r10[218u32] r10[219u32] r10[220u32] r10[221u32] r10[222u32] r10[223u32] r10[224u32] r10[225u32] r10[226u32] r10[227u32] r10[228u32] r10[229u32] r10[230u32] r10[231u32] r10[232u32] r10[233u32] r10[234u32] r10[235u32] r10[236u32] r10[237u32] r10[238u32] r10[239u32] r10[240u32] r10[241u32] r10[242u32] r10[243u32] r10[244u32] r10[245u32] r10[246u32] r10[247u32] r10[248u32] r10[249u32] r10[250u32] r10[251u32] r10[252u32] r11[253u32] r11[254u32] r11[255u32] into r12 as [boolean; 256u32];
    deserialize.bits.raw r12 ([boolean; 256u32]) into r13 ([u8; 32u32]);
    cast 4u8 r13 r3 r1 r0 into r14 as TransferAuth;
    cast 2u8 75u8 194u8 163u8 18u8 101u8 21u8 63u8 7u8 231u8 14u8 11u8 171u8 8u8 114u8 78u8 107u8 133u8 226u8 23u8 248u8 205u8 98u8 140u8 235u8 98u8 151u8 66u8 71u8 187u8 73u8 51u8 130u8 into r15 as [u8; 33u32];
    ecdsa.verify.keccak256.raw r4 r15 r14 into r16;
    assert.eq r16 true;
    set true into used_nonces[r1];
    await r5;

constructor:
    assert.eq edition 0u16;
