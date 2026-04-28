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
    async transfer_public r1 r2 r3 r4 r0 r5 into r6;
    output r6 as virtual_wallet_pubkey.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u64.public;
    input r3 as u32.public;
    input r4 as [u8; 65u32].public;
    input r5 as credits.aleo/transfer_public.future;
    cast r0 into r6 as field;
    serialize.bits.raw r6 (field) into r7 ([boolean; 253u32]);
    cast false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false into r8 as [boolean; 256u32];
    cast r7[0u32] r7[1u32] r7[2u32] r7[3u32] r7[4u32] r7[5u32] r7[6u32] r7[7u32] r7[8u32] r7[9u32] r7[10u32] r7[11u32] r7[12u32] r7[13u32] r7[14u32] r7[15u32] r7[16u32] r7[17u32] r7[18u32] r7[19u32] r7[20u32] r7[21u32] r7[22u32] r7[23u32] r7[24u32] r7[25u32] r7[26u32] r7[27u32] r7[28u32] r7[29u32] r7[30u32] r7[31u32] r7[32u32] r7[33u32] r7[34u32] r7[35u32] r7[36u32] r7[37u32] r7[38u32] r7[39u32] r7[40u32] r7[41u32] r7[42u32] r7[43u32] r7[44u32] r7[45u32] r7[46u32] r7[47u32] r7[48u32] r7[49u32] r7[50u32] r7[51u32] r7[52u32] r7[53u32] r7[54u32] r7[55u32] r7[56u32] r7[57u32] r7[58u32] r7[59u32] r7[60u32] r7[61u32] r7[62u32] r7[63u32] r7[64u32] r7[65u32] r7[66u32] r7[67u32] r7[68u32] r7[69u32] r7[70u32] r7[71u32] r7[72u32] r7[73u32] r7[74u32] r7[75u32] r7[76u32] r7[77u32] r7[78u32] r7[79u32] r7[80u32] r7[81u32] r7[82u32] r7[83u32] r7[84u32] r7[85u32] r7[86u32] r7[87u32] r7[88u32] r7[89u32] r7[90u32] r7[91u32] r7[92u32] r7[93u32] r7[94u32] r7[95u32] r7[96u32] r7[97u32] r7[98u32] r7[99u32] r7[100u32] r7[101u32] r7[102u32] r7[103u32] r7[104u32] r7[105u32] r7[106u32] r7[107u32] r7[108u32] r7[109u32] r7[110u32] r7[111u32] r7[112u32] r7[113u32] r7[114u32] r7[115u32] r7[116u32] r7[117u32] r7[118u32] r7[119u32] r7[120u32] r7[121u32] r7[122u32] r7[123u32] r7[124u32] r7[125u32] r7[126u32] r7[127u32] r7[128u32] r7[129u32] r7[130u32] r7[131u32] r7[132u32] r7[133u32] r7[134u32] r7[135u32] r7[136u32] r7[137u32] r7[138u32] r7[139u32] r7[140u32] r7[141u32] r7[142u32] r7[143u32] r7[144u32] r7[145u32] r7[146u32] r7[147u32] r7[148u32] r7[149u32] r7[150u32] r7[151u32] r7[152u32] r7[153u32] r7[154u32] r7[155u32] r7[156u32] r7[157u32] r7[158u32] r7[159u32] r7[160u32] r7[161u32] r7[162u32] r7[163u32] r7[164u32] r7[165u32] r7[166u32] r7[167u32] r7[168u32] r7[169u32] r7[170u32] r7[171u32] r7[172u32] r7[173u32] r7[174u32] r7[175u32] r7[176u32] r7[177u32] r7[178u32] r7[179u32] r7[180u32] r7[181u32] r7[182u32] r7[183u32] r7[184u32] r7[185u32] r7[186u32] r7[187u32] r7[188u32] r7[189u32] r7[190u32] r7[191u32] r7[192u32] r7[193u32] r7[194u32] r7[195u32] r7[196u32] r7[197u32] r7[198u32] r7[199u32] r7[200u32] r7[201u32] r7[202u32] r7[203u32] r7[204u32] r7[205u32] r7[206u32] r7[207u32] r7[208u32] r7[209u32] r7[210u32] r7[211u32] r7[212u32] r7[213u32] r7[214u32] r7[215u32] r7[216u32] r7[217u32] r7[218u32] r7[219u32] r7[220u32] r7[221u32] r7[222u32] r7[223u32] r7[224u32] r7[225u32] r7[226u32] r7[227u32] r7[228u32] r7[229u32] r7[230u32] r7[231u32] r7[232u32] r7[233u32] r7[234u32] r7[235u32] r7[236u32] r7[237u32] r7[238u32] r7[239u32] r7[240u32] r7[241u32] r7[242u32] r7[243u32] r7[244u32] r7[245u32] r7[246u32] r7[247u32] r7[248u32] r7[249u32] r7[250u32] r7[251u32] r7[252u32] r8[253u32] r8[254u32] r8[255u32] into r9 as [boolean; 256u32];
    deserialize.bits.raw r9 ([boolean; 256u32]) into r10 ([u8; 32u32]);
    cast 3u8 r10 r1 r2 r3 into r11 as TransferAuth;
    cast 2u8 75u8 194u8 163u8 18u8 101u8 21u8 63u8 7u8 231u8 14u8 11u8 171u8 8u8 114u8 78u8 107u8 133u8 226u8 23u8 248u8 205u8 98u8 140u8 235u8 98u8 151u8 66u8 71u8 187u8 73u8 51u8 130u8 into r12 as [u8; 33u32];
    ecdsa.verify.keccak256.raw r4 r12 r11 into r13;
    assert.eq r13 true;
    lt block.height r3 into r14;
    assert.eq r14 true;
    contains used_nonces[r2] into r15;
    not r15 into r16;
    assert.eq r16 true;
    set true into used_nonces[r2];
    await r5;

function transfer_public_to_private:
    input r0 as [u8; 65u32].public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as u64.public;
    input r4 as u32.public;
    call credits.aleo/transfer_public_to_private r1 r2 into r5 r6;
    async transfer_public_to_private r1 r2 r3 r4 r0 r6 into r7;
    output r5 as credits.aleo/credits.record;
    output r7 as virtual_wallet_pubkey.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u64.public;
    input r3 as u32.public;
    input r4 as [u8; 65u32].public;
    input r5 as credits.aleo/transfer_public_to_private.future;
    cast r0 into r6 as field;
    serialize.bits.raw r6 (field) into r7 ([boolean; 253u32]);
    cast false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false into r8 as [boolean; 256u32];
    cast r7[0u32] r7[1u32] r7[2u32] r7[3u32] r7[4u32] r7[5u32] r7[6u32] r7[7u32] r7[8u32] r7[9u32] r7[10u32] r7[11u32] r7[12u32] r7[13u32] r7[14u32] r7[15u32] r7[16u32] r7[17u32] r7[18u32] r7[19u32] r7[20u32] r7[21u32] r7[22u32] r7[23u32] r7[24u32] r7[25u32] r7[26u32] r7[27u32] r7[28u32] r7[29u32] r7[30u32] r7[31u32] r7[32u32] r7[33u32] r7[34u32] r7[35u32] r7[36u32] r7[37u32] r7[38u32] r7[39u32] r7[40u32] r7[41u32] r7[42u32] r7[43u32] r7[44u32] r7[45u32] r7[46u32] r7[47u32] r7[48u32] r7[49u32] r7[50u32] r7[51u32] r7[52u32] r7[53u32] r7[54u32] r7[55u32] r7[56u32] r7[57u32] r7[58u32] r7[59u32] r7[60u32] r7[61u32] r7[62u32] r7[63u32] r7[64u32] r7[65u32] r7[66u32] r7[67u32] r7[68u32] r7[69u32] r7[70u32] r7[71u32] r7[72u32] r7[73u32] r7[74u32] r7[75u32] r7[76u32] r7[77u32] r7[78u32] r7[79u32] r7[80u32] r7[81u32] r7[82u32] r7[83u32] r7[84u32] r7[85u32] r7[86u32] r7[87u32] r7[88u32] r7[89u32] r7[90u32] r7[91u32] r7[92u32] r7[93u32] r7[94u32] r7[95u32] r7[96u32] r7[97u32] r7[98u32] r7[99u32] r7[100u32] r7[101u32] r7[102u32] r7[103u32] r7[104u32] r7[105u32] r7[106u32] r7[107u32] r7[108u32] r7[109u32] r7[110u32] r7[111u32] r7[112u32] r7[113u32] r7[114u32] r7[115u32] r7[116u32] r7[117u32] r7[118u32] r7[119u32] r7[120u32] r7[121u32] r7[122u32] r7[123u32] r7[124u32] r7[125u32] r7[126u32] r7[127u32] r7[128u32] r7[129u32] r7[130u32] r7[131u32] r7[132u32] r7[133u32] r7[134u32] r7[135u32] r7[136u32] r7[137u32] r7[138u32] r7[139u32] r7[140u32] r7[141u32] r7[142u32] r7[143u32] r7[144u32] r7[145u32] r7[146u32] r7[147u32] r7[148u32] r7[149u32] r7[150u32] r7[151u32] r7[152u32] r7[153u32] r7[154u32] r7[155u32] r7[156u32] r7[157u32] r7[158u32] r7[159u32] r7[160u32] r7[161u32] r7[162u32] r7[163u32] r7[164u32] r7[165u32] r7[166u32] r7[167u32] r7[168u32] r7[169u32] r7[170u32] r7[171u32] r7[172u32] r7[173u32] r7[174u32] r7[175u32] r7[176u32] r7[177u32] r7[178u32] r7[179u32] r7[180u32] r7[181u32] r7[182u32] r7[183u32] r7[184u32] r7[185u32] r7[186u32] r7[187u32] r7[188u32] r7[189u32] r7[190u32] r7[191u32] r7[192u32] r7[193u32] r7[194u32] r7[195u32] r7[196u32] r7[197u32] r7[198u32] r7[199u32] r7[200u32] r7[201u32] r7[202u32] r7[203u32] r7[204u32] r7[205u32] r7[206u32] r7[207u32] r7[208u32] r7[209u32] r7[210u32] r7[211u32] r7[212u32] r7[213u32] r7[214u32] r7[215u32] r7[216u32] r7[217u32] r7[218u32] r7[219u32] r7[220u32] r7[221u32] r7[222u32] r7[223u32] r7[224u32] r7[225u32] r7[226u32] r7[227u32] r7[228u32] r7[229u32] r7[230u32] r7[231u32] r7[232u32] r7[233u32] r7[234u32] r7[235u32] r7[236u32] r7[237u32] r7[238u32] r7[239u32] r7[240u32] r7[241u32] r7[242u32] r7[243u32] r7[244u32] r7[245u32] r7[246u32] r7[247u32] r7[248u32] r7[249u32] r7[250u32] r7[251u32] r7[252u32] r8[253u32] r8[254u32] r8[255u32] into r9 as [boolean; 256u32];
    deserialize.bits.raw r9 ([boolean; 256u32]) into r10 ([u8; 32u32]);
    cast 4u8 r10 r1 r2 r3 into r11 as TransferAuth;
    cast 2u8 75u8 194u8 163u8 18u8 101u8 21u8 63u8 7u8 231u8 14u8 11u8 171u8 8u8 114u8 78u8 107u8 133u8 226u8 23u8 248u8 205u8 98u8 140u8 235u8 98u8 151u8 66u8 71u8 187u8 73u8 51u8 130u8 into r12 as [u8; 33u32];
    ecdsa.verify.keccak256.raw r4 r12 r11 into r13;
    assert.eq r13 true;
    lt block.height r3 into r14;
    assert.eq r14 true;
    contains used_nonces[r2] into r15;
    not r15 into r16;
    assert.eq r16 true;
    set true into used_nonces[r2];
    await r5;

constructor:
    assert.eq edition 0u16;
