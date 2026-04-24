import credits.aleo;
program virtual_wallet.aleo;

struct TransferAuth:
    selector as u8;
    owner_eth as [u8; 20u32];
    to_bytes as [u8; 32u32];
    amount as u64;
    nonce as u64;
    expiry as u32;

struct NonceKey:
    owner_eth as [u8; 20u32];
    nonce as u64;

mapping used_nonces:
    key as NonceKey.public;
    value as boolean.public;

function transfer_public:
    input r0 as [u8; 20u32].public;
    input r1 as [u8; 65u32].public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as u64.public;
    input r5 as u32.public;
    call credits.aleo/transfer_public r2 r3 into r6;
    async transfer_public r0 r2 r3 r4 r5 r1 r6 into r7;
    output r7 as virtual_wallet.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as [u8; 20u32].public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as u64.public;
    input r4 as u32.public;
    input r5 as [u8; 65u32].public;
    input r6 as credits.aleo/transfer_public.future;
    cast r1 into r7 as field;
    serialize.bits.raw r7 (field) into r8 ([boolean; 253u32]);
    cast false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false into r9 as [boolean; 256u32];
    cast r8[0u32] r8[1u32] r8[2u32] r8[3u32] r8[4u32] r8[5u32] r8[6u32] r8[7u32] r8[8u32] r8[9u32] r8[10u32] r8[11u32] r8[12u32] r8[13u32] r8[14u32] r8[15u32] r8[16u32] r8[17u32] r8[18u32] r8[19u32] r8[20u32] r8[21u32] r8[22u32] r8[23u32] r8[24u32] r8[25u32] r8[26u32] r8[27u32] r8[28u32] r8[29u32] r8[30u32] r8[31u32] r8[32u32] r8[33u32] r8[34u32] r8[35u32] r8[36u32] r8[37u32] r8[38u32] r8[39u32] r8[40u32] r8[41u32] r8[42u32] r8[43u32] r8[44u32] r8[45u32] r8[46u32] r8[47u32] r8[48u32] r8[49u32] r8[50u32] r8[51u32] r8[52u32] r8[53u32] r8[54u32] r8[55u32] r8[56u32] r8[57u32] r8[58u32] r8[59u32] r8[60u32] r8[61u32] r8[62u32] r8[63u32] r8[64u32] r8[65u32] r8[66u32] r8[67u32] r8[68u32] r8[69u32] r8[70u32] r8[71u32] r8[72u32] r8[73u32] r8[74u32] r8[75u32] r8[76u32] r8[77u32] r8[78u32] r8[79u32] r8[80u32] r8[81u32] r8[82u32] r8[83u32] r8[84u32] r8[85u32] r8[86u32] r8[87u32] r8[88u32] r8[89u32] r8[90u32] r8[91u32] r8[92u32] r8[93u32] r8[94u32] r8[95u32] r8[96u32] r8[97u32] r8[98u32] r8[99u32] r8[100u32] r8[101u32] r8[102u32] r8[103u32] r8[104u32] r8[105u32] r8[106u32] r8[107u32] r8[108u32] r8[109u32] r8[110u32] r8[111u32] r8[112u32] r8[113u32] r8[114u32] r8[115u32] r8[116u32] r8[117u32] r8[118u32] r8[119u32] r8[120u32] r8[121u32] r8[122u32] r8[123u32] r8[124u32] r8[125u32] r8[126u32] r8[127u32] r8[128u32] r8[129u32] r8[130u32] r8[131u32] r8[132u32] r8[133u32] r8[134u32] r8[135u32] r8[136u32] r8[137u32] r8[138u32] r8[139u32] r8[140u32] r8[141u32] r8[142u32] r8[143u32] r8[144u32] r8[145u32] r8[146u32] r8[147u32] r8[148u32] r8[149u32] r8[150u32] r8[151u32] r8[152u32] r8[153u32] r8[154u32] r8[155u32] r8[156u32] r8[157u32] r8[158u32] r8[159u32] r8[160u32] r8[161u32] r8[162u32] r8[163u32] r8[164u32] r8[165u32] r8[166u32] r8[167u32] r8[168u32] r8[169u32] r8[170u32] r8[171u32] r8[172u32] r8[173u32] r8[174u32] r8[175u32] r8[176u32] r8[177u32] r8[178u32] r8[179u32] r8[180u32] r8[181u32] r8[182u32] r8[183u32] r8[184u32] r8[185u32] r8[186u32] r8[187u32] r8[188u32] r8[189u32] r8[190u32] r8[191u32] r8[192u32] r8[193u32] r8[194u32] r8[195u32] r8[196u32] r8[197u32] r8[198u32] r8[199u32] r8[200u32] r8[201u32] r8[202u32] r8[203u32] r8[204u32] r8[205u32] r8[206u32] r8[207u32] r8[208u32] r8[209u32] r8[210u32] r8[211u32] r8[212u32] r8[213u32] r8[214u32] r8[215u32] r8[216u32] r8[217u32] r8[218u32] r8[219u32] r8[220u32] r8[221u32] r8[222u32] r8[223u32] r8[224u32] r8[225u32] r8[226u32] r8[227u32] r8[228u32] r8[229u32] r8[230u32] r8[231u32] r8[232u32] r8[233u32] r8[234u32] r8[235u32] r8[236u32] r8[237u32] r8[238u32] r8[239u32] r8[240u32] r8[241u32] r8[242u32] r8[243u32] r8[244u32] r8[245u32] r8[246u32] r8[247u32] r8[248u32] r8[249u32] r8[250u32] r8[251u32] r8[252u32] r9[253u32] r9[254u32] r9[255u32] into r10 as [boolean; 256u32];
    deserialize.bits.raw r10 ([boolean; 256u32]) into r11 ([u8; 32u32]);
    cast 1u8 r0 r11 r2 r3 r4 into r12 as TransferAuth;
    ecdsa.verify.keccak256.eth r5 r0 r12 into r13;
    assert.eq r13 true;
    lt block.height r4 into r14;
    assert.eq r14 true;
    cast r0 r3 into r15 as NonceKey;
    contains used_nonces[r15] into r16;
    not r16 into r17;
    assert.eq r17 true;
    set true into used_nonces[r15];
    await r6;

function transfer_public_to_private:
    input r0 as [u8; 20u32].public;
    input r1 as [u8; 65u32].public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as u64.public;
    input r5 as u32.public;
    call credits.aleo/transfer_public_to_private r2 r3 into r6 r7;
    async transfer_public_to_private r0 r2 r3 r4 r5 r1 r7 into r8;
    output r6 as credits.aleo/credits.record;
    output r8 as virtual_wallet.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as [u8; 20u32].public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as u64.public;
    input r4 as u32.public;
    input r5 as [u8; 65u32].public;
    input r6 as credits.aleo/transfer_public_to_private.future;
    cast r1 into r7 as field;
    serialize.bits.raw r7 (field) into r8 ([boolean; 253u32]);
    cast false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false false into r9 as [boolean; 256u32];
    cast r8[0u32] r8[1u32] r8[2u32] r8[3u32] r8[4u32] r8[5u32] r8[6u32] r8[7u32] r8[8u32] r8[9u32] r8[10u32] r8[11u32] r8[12u32] r8[13u32] r8[14u32] r8[15u32] r8[16u32] r8[17u32] r8[18u32] r8[19u32] r8[20u32] r8[21u32] r8[22u32] r8[23u32] r8[24u32] r8[25u32] r8[26u32] r8[27u32] r8[28u32] r8[29u32] r8[30u32] r8[31u32] r8[32u32] r8[33u32] r8[34u32] r8[35u32] r8[36u32] r8[37u32] r8[38u32] r8[39u32] r8[40u32] r8[41u32] r8[42u32] r8[43u32] r8[44u32] r8[45u32] r8[46u32] r8[47u32] r8[48u32] r8[49u32] r8[50u32] r8[51u32] r8[52u32] r8[53u32] r8[54u32] r8[55u32] r8[56u32] r8[57u32] r8[58u32] r8[59u32] r8[60u32] r8[61u32] r8[62u32] r8[63u32] r8[64u32] r8[65u32] r8[66u32] r8[67u32] r8[68u32] r8[69u32] r8[70u32] r8[71u32] r8[72u32] r8[73u32] r8[74u32] r8[75u32] r8[76u32] r8[77u32] r8[78u32] r8[79u32] r8[80u32] r8[81u32] r8[82u32] r8[83u32] r8[84u32] r8[85u32] r8[86u32] r8[87u32] r8[88u32] r8[89u32] r8[90u32] r8[91u32] r8[92u32] r8[93u32] r8[94u32] r8[95u32] r8[96u32] r8[97u32] r8[98u32] r8[99u32] r8[100u32] r8[101u32] r8[102u32] r8[103u32] r8[104u32] r8[105u32] r8[106u32] r8[107u32] r8[108u32] r8[109u32] r8[110u32] r8[111u32] r8[112u32] r8[113u32] r8[114u32] r8[115u32] r8[116u32] r8[117u32] r8[118u32] r8[119u32] r8[120u32] r8[121u32] r8[122u32] r8[123u32] r8[124u32] r8[125u32] r8[126u32] r8[127u32] r8[128u32] r8[129u32] r8[130u32] r8[131u32] r8[132u32] r8[133u32] r8[134u32] r8[135u32] r8[136u32] r8[137u32] r8[138u32] r8[139u32] r8[140u32] r8[141u32] r8[142u32] r8[143u32] r8[144u32] r8[145u32] r8[146u32] r8[147u32] r8[148u32] r8[149u32] r8[150u32] r8[151u32] r8[152u32] r8[153u32] r8[154u32] r8[155u32] r8[156u32] r8[157u32] r8[158u32] r8[159u32] r8[160u32] r8[161u32] r8[162u32] r8[163u32] r8[164u32] r8[165u32] r8[166u32] r8[167u32] r8[168u32] r8[169u32] r8[170u32] r8[171u32] r8[172u32] r8[173u32] r8[174u32] r8[175u32] r8[176u32] r8[177u32] r8[178u32] r8[179u32] r8[180u32] r8[181u32] r8[182u32] r8[183u32] r8[184u32] r8[185u32] r8[186u32] r8[187u32] r8[188u32] r8[189u32] r8[190u32] r8[191u32] r8[192u32] r8[193u32] r8[194u32] r8[195u32] r8[196u32] r8[197u32] r8[198u32] r8[199u32] r8[200u32] r8[201u32] r8[202u32] r8[203u32] r8[204u32] r8[205u32] r8[206u32] r8[207u32] r8[208u32] r8[209u32] r8[210u32] r8[211u32] r8[212u32] r8[213u32] r8[214u32] r8[215u32] r8[216u32] r8[217u32] r8[218u32] r8[219u32] r8[220u32] r8[221u32] r8[222u32] r8[223u32] r8[224u32] r8[225u32] r8[226u32] r8[227u32] r8[228u32] r8[229u32] r8[230u32] r8[231u32] r8[232u32] r8[233u32] r8[234u32] r8[235u32] r8[236u32] r8[237u32] r8[238u32] r8[239u32] r8[240u32] r8[241u32] r8[242u32] r8[243u32] r8[244u32] r8[245u32] r8[246u32] r8[247u32] r8[248u32] r8[249u32] r8[250u32] r8[251u32] r8[252u32] r9[253u32] r9[254u32] r9[255u32] into r10 as [boolean; 256u32];
    deserialize.bits.raw r10 ([boolean; 256u32]) into r11 ([u8; 32u32]);
    cast 2u8 r0 r11 r2 r3 r4 into r12 as TransferAuth;
    ecdsa.verify.keccak256.eth r5 r0 r12 into r13;
    assert.eq r13 true;
    lt block.height r4 into r14;
    assert.eq r14 true;
    cast r0 r3 into r15 as NonceKey;
    contains used_nonces[r15] into r16;
    not r16 into r17;
    assert.eq r17 true;
    set true into used_nonces[r15];
    await r6;

constructor:
    assert.eq edition 0u16;
