program gold_token.aleo;

record Token:
    owner as address.private;
    amount as u64.private;
    purity as u64.private;

function mint:
    input r0 as address.private;
    input r1 as u64.private;
    cast r0 r1 24u64 into r2 as Token.record;
    output r2 as Token.record;

function mint_custom:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as u64.private;
    gte r2 1u64 into r3;
    lte r2 24u64 into r4;
    and r3 r4 into r5;
    assert.eq r5 true;
    cast r0 r1 r2 into r6 as Token.record;
    output r6 as Token.record;

function transfer:
    input r0 as dynamic.record;
    input r1 as address.private;
    get.record.dynamic r0.amount into r2 as u64;
    get.record.dynamic r0.purity into r3 as u64;
    cast r1 r2 r3 into r4 as Token.record;
    cast r4 into r5 as dynamic.record;
    output r5 as dynamic.record;

function balance_of:
    input r0 as dynamic.record;
    get.record.dynamic r0.amount into r1 as u64;
    output r1 as u64.private;

constructor:
    assert.eq edition 0u16;
