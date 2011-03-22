(*----------------------------------------------------------------

	User Module, queries for actions.

----------------------------------------------------------------*)
MODULE UserM;
	IMPORT Out, In, DealerO, UtilsM;
	VAR
		query: ARRAY 4 OF CHAR; (* size of user string input *)
		questionDepth: INTEGER; (* depth in the menu *)
		dealer: DealerO.DealerClassPointer; (* the dealer which acts as an interface for players and decks *)

	(*
		Cards Printing.

		@param INTEGER depth: in the menu
		@return INTEGER depth: to return to
	*)
	PROCEDURE printCards*(VAR depth: INTEGER): INTEGER;
	VAR
		result: BOOLEAN;
	BEGIN
		questionDepth := 1;
		REPEAT
			(* ask which deck or hand to print *)
			Out.String("-------------------------------------"); Out.Ln;
			dealer.showLists();
			Out.String("Actions: Show [D]eck, Show [P]layer, [B]ack "); In.Line(query);

			(* show a deck *)
			IF (query = 'D') THEN
				REPEAT
					(* ask which deck to print *)
					Out.String("-------------------------------------"); Out.Ln;
					Out.String("Actions: [B]ack"); Out.Ln; Out.String("Dealer: Deck number? "); In.Line(query);
				
					IF (query = 'B') THEN RETURN depth - 1;
					ELSE
						result := dealer.print('D', query[0]); (* print a deck of cards *)
						IF (result = FALSE) THEN Out.String("Dealer: Deck does not exist."); Out.Ln; END;
					END;
				UNTIL FALSE;

			(* show player's hand *)
			ELSIF (query = 'P') THEN
				REPEAT
					(* ask which hand to print *)
					Out.String("-------------------------------------"); Out.Ln;
					Out.String("Actions: [B]ack"); Out.Ln; Out.String("Dealer: Player number? "); In.Line(query);
				
					IF (query = 'B') THEN RETURN depth - 1;
					ELSE
						result := dealer.print('P', query[0]); (* print a hand of cards *)
						IF (result = FALSE) THEN Out.String("Dealer: Player does not exist."); Out.Ln; END;
					END;
				UNTIL FALSE;

			(* return *)
			ELSIF (query = 'B') THEN RETURN depth - 1;
			END;
		UNTIL questionDepth # 1;

	END printCards;

	(*
		Deck cutting after cards have been shuffled.

		@param void
		@return void
	*)
	PROCEDURE cutDeck*();
	VAR
		string*: UtilsM.String;
		range: INTEGER; (* range for cutting point *)
		result: BOOLEAN;
	BEGIN
		REPEAT
			(* ask where in the deck to cut (2..50) *)
			Out.String("Dealer: Where do you wish to cut [2-50]? "); In.Line(query);
			string.chars[0] := query[0];
			string.chars[1] := query[1];
			range := UtilsM.toInt(string); (* convert string to integer *)

			IF (range > 1) & (range < 51) THEN (* contiguous ranges *)
				result := dealer.cutDeck(range);

				IF (result # FALSE) THEN
					questionDepth := 2;

					REPEAT
						(* cut the deck making 2 *)
						Out.String("-------------------------------------"); Out.Ln;
						Out.String("Actions: [S]huffle, [D]eal, [R]eturn, [P]rint "); In.Line(query);
		
						IF (query = 'S') THEN (* shuffle, a reset *)
							NEW(dealer);
							dealer.initDeck();
							dealer.shuffleDeck();
							(* return back to the main menu *)			
							RETURN;

						ELSIF (query = 'D') THEN (* dealing *)
							questionDepth := 2;
							questionDepth := dealCards(questionDepth);
				
						ELSIF (query = 'R') THEN (* return cards back to the deck *)
							questionDepth := 2;
							questionDepth := returnCard(questionDepth);

						ELSIF (query = 'P') THEN (* printing *)
							questionDepth := 3;
							questionDepth := printCards(questionDepth);
						END;
					UNTIL questionDepth # 2;

				END;

			END;
		UNTIL questionDepth # 1;

	END cutDeck;

	(*
		Deal from a deck of cards once it has been cut.

		@param INTEGER depth: in the menu
		@return INTEGER depth: to return to
	*)
	PROCEDURE dealCards*(VAR depth: INTEGER): INTEGER;
	VAR
		string*: UtilsM.String;
		cards: INTEGER;
		players: INTEGER;
	BEGIN
		REPEAT
			(* ask how many cards to deal *)
			Out.String("Dealer: How many cards? "); In.Line(query);
			string.chars[0] := query[0];
			string.chars[1] := query[1];
			cards := UtilsM.toInt(string); (* convert string to integer *)

			(* ask how many players to deal to *)
			Out.String("Dealer: To how many players [1-9]? "); In.Line(query);
			string.chars[0] := query[0];
			string.chars[1] := query[1];
			players := UtilsM.toInt(string); (* convert string to integer *)

			IF (cards > 0) & (players > 0) & (players < 10) THEN
				dealer.dealCards(cards, players);
				RETURN 2;
			END;
		UNTIL FALSE;

	END dealCards;

	(*
		Return a card back to the deck.

		@param INTEGER depth: in the menu
		@return INTEGER depth: to return to
	*)
	PROCEDURE returnCard*(VAR depth: INTEGER): INTEGER;
	VAR
		player: INTEGER;
	BEGIN
		REPEAT
			(* ask how many players to deal to *)
			Out.String("Dealer: From which player [1-9]? "); In.Int(player);

			IF (player > 0) & (player < 10) THEN
				dealer.returnCard(player);
				RETURN 2;
			END;
		UNTIL FALSE;

	END returnCard;

	(*
		Main loop of a menu.

		@param void
		@return void
	*)
	BEGIN
		(* creates a dealer and a deck of 52 sorted cards *)
		NEW(dealer);
		dealer.initDeck();
		REPEAT
			Out.String("-------------------------------------"); Out.Ln;
			Out.String("Actions: [S]huffle, [C]ut, [P]rint "); In.Line(query);
		
			IF (query = 'S') THEN (* cards shuffle *)
				dealer.shuffleDeck();

			ELSIF (query = 'C') THEN (* deck cut *)
				cutDeck();

			ELSIF (query = 'P') THEN (* printing *)
				questionDepth := 2;
				questionDepth := printCards(questionDepth);

			END;
		UNTIL FALSE;

END UserM.
