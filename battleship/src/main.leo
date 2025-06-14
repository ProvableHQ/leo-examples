import board.aleo;
import move.aleo;
import verify.aleo;

// The 'battleship.aleo' program.
program battleship.aleo {
    // Returns a new record representing a new game of battleship.
    transition initialize_board(
        // The u64 representation of a carrier's placement in an 8x8 grid. Length = 5.
        carrier: u64,
        // The u64 representation of a battleship's placement in an 8x8 grid. Length = 4.
        battleship: u64,
        // The u64 representation of a cruiser's placement in an 8x8 grid. Length = 3.
        cruiser: u64,
        // The u64 representation of a destroyer's placement in an 8x8 grid. Length = 2.
        destroyer: u64,
        // The address of the opponent.
        player: address,
    ) -> board.aleo/BoardState {
        // Verify that each individual ship placement bitstring is valid.
        let valid_carrier: bool = verify.aleo/validate_ship(carrier, 5u64, 31u64, 4311810305u64);
        assert(valid_carrier);

        let valid_battleship: bool = verify.aleo/validate_ship(battleship, 4u64, 15u64, 16843009u64);
        assert(valid_battleship);

        let valid_cruiser: bool = verify.aleo/validate_ship(cruiser, 3u64, 7u64, 65793u64);
        assert(valid_cruiser);

        let valid_destroyer: bool = verify.aleo/validate_ship(destroyer, 2u64, 3u64, 257u64);
        assert(valid_destroyer);

        // Create the board with all the ship placements combined.
        let board: u64 = verify.aleo/create_board(carrier, battleship, cruiser, destroyer);

        // Initialize the board state record.
        let state: board.aleo/BoardState = board.aleo/new_board_state(board, player);

        return state;
    }

    // Returns an updated board state record that has been started. This board cannot be used to start any other games.
    // Returns a dummy move record owned by the opponent.
    // This function commits a given board to a game with an opponent and creates the initial dummy move.
    transition offer_battleship(
        // The board record to start a game with.
        board: board.aleo/BoardState,
    ) -> (board.aleo/BoardState, move.aleo/Move) {
        let state: board.aleo/BoardState = board.aleo/start_board(board);
        let dummy: move.aleo/Move = move.aleo/start_game(board.player_2);

        return (state, dummy);
    }

    // Returns updated board_state that has been started and can no longer be used to join or start new games.
    // Returns dummy move record owned by the opponent.
    transition start_battleship(
        // The board record to play the game with.
        board: board.aleo/BoardState,
        // The move record to play to begin the game. This should be the dummy move record created from offer_battleship.
        move_start: move.aleo/Move,
    ) -> (board.aleo/BoardState, move.aleo/Move) {
        // Validate that the move players and board players match each other.
        assert_eq(board.player_1, move_start.player_2);
        assert_eq(board.player_2, move_start.player_1);

        let state: board.aleo/BoardState = board.aleo/start_board(board);
        let dummy: move.aleo/Move = move.aleo/start_game(board.player_2);

        return (state, dummy);
    }

    // Returns updated board record.
    // Returns new move record owned by opponent.
    transition play(
        // The board record to update.
        board: board.aleo/BoardState,
        // The incoming move from the opponent.
        move_incoming: move.aleo/Move,
        // The u64 equivalent of the bitwise representation of the next coordinate to play on the opponent's board.
        shoot: u64,
    ) -> (board.aleo/BoardState, move.aleo/Move) {
        // Verify the board has been started. This prevents players from starting a game and then creating
        // a brand new board to play with.
        assert(board.game_started);

        // Validate that the move players and board players match each other.
        assert_eq(board.player_1, move_incoming.player_2);
        assert_eq(board.player_2, move_incoming.player_1);

        // Play coordinate on own board. Will fail if not a valid move.
        let hit_or_miss: board.aleo/BoardState = board.aleo/update_played_tiles(board, shoot);

        // Update own board with result of last shot.
        let next_board: board.aleo/BoardState = board.aleo/update_hits_and_misses(hit_or_miss, move_incoming.prev_hit_or_miss);

        // Assess whether incoming fire coordinate is a hit.
        let is_hit: u64 = move_incoming.incoming_fire_coordinate & board.ships;

        let next_move: move.aleo/Move = move.aleo/create_move(move_incoming, shoot, is_hit);

        return (next_board, next_move);
    }
}

