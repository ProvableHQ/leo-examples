program move.aleo;

record Move:
    owner as address.private;
    incoming_fire_coordinate as u64.private;
    player_1 as address.private;
    player_2 as address.private;
    prev_hit_or_miss as u64.private;

function create_move:
    input r0 as Move.record;
    input r1 as u64.private;
    input r2 as u64.private;
    is.eq r0.player_1 r0.owner into r3;
    ternary r3 r0.player_2 r0.player_1 into r4;
    cast r4 r1 r0.player_2 r0.player_1 r2 into r5 as Move.record;
    output r5 as Move.record;

function start_game:
    input r0 as address.private;
    cast r0 0u64 self.caller r0 0u64 into r1 as Move.record;
    output r1 as Move.record;
