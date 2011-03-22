(*----------------------------------------------------------------

	Dealer Class, knows lists (stacks) of cards.

----------------------------------------------------------------*)
MODULE DealerO;
	IMPORT Out, CardsListO;
	TYPE
		(* pointer to List node *)
		Node* = POINTER TO NodeBlock;
		NodeBlock =
			RECORD
				data*: CardsListO.ListClassPointer; (* the actual cards contained *)
				owner*: ARRAY 2 OF CHAR; (* e.g.: D1 = Deck 1 etc. *)
				next*: Node;
			END;

		(* class definition *)
		DealerClassPointer* = POINTER TO DealerClass;
		DealerClass* =
			RECORD
				head*: Node;
				tail*: Node; (* pointing to the last node, which is always D1 *)
			END;

	(*
		Add a deck or player's hand.

		@param CHAR type: 'D' or 'P'
		@param CHAR number: CHAR numeric representation of the owner
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) addList(type: CHAR; number: CHAR);
	VAR
		temp: Node;
		tempList: CardsListO.ListClassPointer;
	BEGIN
		NEW(temp);
		temp^.next := dealer^.head;

		NEW(tempList);
		temp^.data := tempList;
		temp^.owner[0] := type;
		temp^.owner[1] := number;
		dealer^.head := temp;

		IF (type = 'D') THEN Out.String("Dealer: Added deck ");
		ELSE Out.String("Dealer: Added player ");
		END;
		Out.Char(temp^.owner[0]); Out.Char(temp^.owner[1]); Out.Char("."); Out.Ln;
	END addList;

	(*
		Initialize a List of cards (D1) with 52 cards in order.

		@param void
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) initDeck*();
	BEGIN
		dealer^.addList('D', '1');
		(* as we add to the front only make a link to tail if we add D1 *)
		dealer^.tail := dealer^.head;
		dealer^.createSuit('H'); dealer^.createSuit('C'); dealer^.createSuit('D'); dealer^.createSuit('S');
	END initDeck;

	(*
		Create 13 cards of a given suit in D1.

		@param CHAR suit: either of H, C, D, S
		@param INTEGER offset: by multiples of 13
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) createSuit(suit: CHAR);
	VAR
		pointer: INTEGER;
		result: BOOLEAN;
	BEGIN
		pointer := 0;
		WHILE (pointer < 13) DO
			(* the rank *)			
			IF (pointer = 0) THEN result := dealer^.addCard('D', '1', suit, 'A');
			ELSIF (pointer < 9) THEN result := dealer^.addCard('D', '1', suit, CHR(pointer + 49)); (* convert INT to CHAR *)
			ELSIF (pointer = 9) THEN result := dealer^.addCard('D', '1', suit, '0'); (* represents '10' *)
			ELSIF (pointer = 10) THEN result := dealer^.addCard('D', '1', suit, 'J');
			ELSIF (pointer = 11) THEN result := dealer^.addCard('D', '1', suit, 'Q');
			ELSIF (pointer = 12) THEN result := dealer^.addCard('D', '1', suit, 'K');
			END;
			IF (result # TRUE) THEN Out.String("System: Failed to add a card in procedure createSuit()."); Out.Ln; END;
			pointer := pointer + 1;
		END;
	END createSuit;

	(*
		Add a card to an existing List.

		@param CHAR type: 'D' or 'P'
		@param CHAR number: CHAR numeric representation of the owner
		@param CHAR suit: H, C, D, S
		@param CHAR rank: A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
		@return BOOLEAN: TRUE on succesfull add, otherwise List not found and FALSE
	*)
	PROCEDURE (dealer: DealerClassPointer) addCard(type: CHAR; number: CHAR; suit: CHAR; rank: CHAR): BOOLEAN;
	VAR
		temp: Node;
	BEGIN
		temp := dealer.head;
		WHILE temp # NIL DO
			IF (temp^.owner[0] = type) & (temp^.owner[1] = number) THEN
				temp^.data^.addCard(suit, rank);
				RETURN TRUE;
			END;
			temp := temp^.next;
		END;
		RETURN FALSE;
	END addCard;

	(*
		Shuffle the 52 cards in Deck 1 (highly redundant and costly).

		@param void
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) shuffleDeck*();
	VAR
		deck: Node;
	BEGIN
		deck := dealer.tail;
		deck^.data^.shuffle();
		Out.String("Dealer: All cards shuffled."); Out.Ln;
	END shuffleDeck;

	(*
		Cut a deck of cards in two.

		@param INTEGER range: cutting point
		@return BOOLEAN: FALSE if problem with deck cutting
	*)
	PROCEDURE (dealer: DealerClassPointer) cutDeck*(range: INTEGER): BOOLEAN;
	VAR
		temp: INTEGER;
		result: BOOLEAN;
	BEGIN
		dealer^.addList('D', '2'); (* add the second List *)
		temp := 0;		
		WHILE temp # range DO (* loop through the cards we need... *)
			result := dealer^.moveCard('D', '1', 'D', '2'); (* ...and add them to the second pile *)
			temp := temp + 1;
		END;
		IF (result # TRUE) THEN Out.String("System: Failed to cut the deck in procedure cutDeck()."); Out.Ln; RETURN FALSE; END;
		RETURN TRUE;
	END cutDeck;

	(*
		Deal from a 1st deck of cards to a number of players.

		@param INTEGER cards: how many cards to deal		
		@param INTEGER players: number of players we are dealing to
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) dealCards*(cards: INTEGER; players: INTEGER);
	VAR
		cardsAmount: INTEGER;
		playerChar: CHAR; (* so we can convert INTEGER to CHAR *)
		result: BOOLEAN;
	BEGIN
		IF (players * cards > dealer^.cardCount('D', '1')) THEN Out.String("Dealer: Not enough cards on the deck."); Out.Ln;
		ELSE
			cardsAmount := cards; (* save the number of cards we will be dealing so we can use as a pointer *)
			WHILE players > 0 DO (* for each player we have to deal to... *)
								
				playerChar := CHR(players + 48); (* determine the player's CHARm (sic.) *)
				IF (dealer^.exists('P', playerChar) = FALSE) THEN (* check/add the player *)
					dealer^.addList('P', playerChar);
				END;

				cardsAmount := cards;
				WHILE cardsAmount > 0 DO (* for all the cards we need to deal *)
					result := dealer^.moveCard('D', '1', 'P', playerChar); (* move them to the player *)
					IF (result # TRUE) THEN Out.String("System: Failed to deal a card in procedure dealCards()."); Out.Ln; END;
					cardsAmount := cardsAmount - 1;
				END;
				players := players - 1;
			END;
		END;
	END dealCards;

	(*
		Return card to the second pile.
	
		@param INTEGER players: the number of the player
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) returnCard*(player: INTEGER);
	VAR
		playerChar: CHAR; (* so we can convert INTEGER to CHAR *)
		result: BOOLEAN;
	BEGIN
		playerChar := CHR(player + 48); (* determine the player's CHARm (sic.) *)
		result := dealer^.moveCard('P', playerChar, 'D', '2');
		IF (result # TRUE) THEN Out.String("Dealer: No cards were returned."); Out.Ln; END;
	END returnCard;

	(*
		Finds out if a given List exists.

		@param CHAR type: 'D' or 'P'
		@param CHAR number: CHAR numeric representation of the owner
		@return BOOLEAN: FALSE returned if a List doesn't exist
	*)
	PROCEDURE (dealer: DealerClassPointer) exists(type: CHAR; number: CHAR): BOOLEAN;
	VAR
		temp: Node;
	BEGIN
		temp := dealer.head;
		WHILE temp # NIL DO
			IF (temp^.owner[0] = type) & (temp^.owner[1] = number) THEN	RETURN TRUE; END;
			temp := temp^.next;
		END;
		RETURN FALSE;
	END exists;

	(*
		Get the number of cards in a given deck (wo/relying on a flag in the data structure).

		@param CHAR type: 'D' or 'P'
		@param CHAR number: CHAR numeric representation of the owner
		@return INTEGER: the number of cards in the deck
	*)
	PROCEDURE (dealer: DealerClassPointer) cardCount(type: CHAR; number: CHAR): INTEGER;
	VAR
		temp: Node;
	BEGIN
		temp := dealer.head;
		WHILE temp # NIL DO
			IF (temp^.owner[0] = type) & (temp^.owner[1] = number) THEN (* find the List we need... *)
				RETURN temp^.data^.count(); (* ...return the number of cards *)
			END;
			temp := temp^.next;
		END;
		RETURN 0; (* we don't have this deck, send 0 *)
	END cardCount;

	(*
		Move one card from a List to another.

		@param CHAR sourceType: 'D' or 'P'
		@param CHAR sourceNumber: CHAR numeric representation of the current owner
		@param CHAR targetType: 'D' or 'P'
		@param CHAR targetNumber: CHAR numeric representation of the new owner
		@return BOOLEAN: TRUE on succesfull add, otherwise List not found and FALSE
	*)
	PROCEDURE (dealer: DealerClassPointer) moveCard(sourceType: CHAR; sourceNumber: CHAR; targetType: CHAR; targetNumber: CHAR): BOOLEAN;
	VAR
		temp: Node;
		sourceList: Node; (* from here... *)
		targetList: Node; (* to here... *)
		discardedCard: CardsListO.Node; (* the card we are moving via pointer *)
		cardValue: ARRAY 2 OF CHAR; (* the actual suit, rank combo *)
	BEGIN
		temp := dealer.head;
		(* one traversal (albeit full one) through the Lists to find both source and target Nodes (Lists) *)
		WHILE temp # NIL DO
			IF (temp^.owner[0] = sourceType) & (temp^.owner[1] = sourceNumber) THEN sourceList := temp;
			ELSIF (temp^.owner[0] = targetType) & (temp^.owner[1] = targetNumber) THEN targetList := temp;
			END;
			(* move pivot *)
			IF (sourceList # NIL) & (targetList # NIL) THEN temp := NIL; ELSE temp := temp^.next; END;
		END;

		(* make the transfer *)
		IF (sourceList # NIL) & (targetList # NIL) THEN
			(* discard a card from source *)
			discardedCard := sourceList^.data.disCard();
			IF (discardedCard = NIL) THEN RETURN FALSE; END;
			(* determine value *)
			cardValue[0] := discardedCard^.data.suit;
			cardValue[1] := discardedCard^.data.rank;
			(* add to the target pile *)
			targetList^.data.addCard(cardValue[0], cardValue[1]);
			RETURN TRUE;
		ELSE RETURN FALSE;
		END;
	END moveCard;

	(*
		Print cards in a given List.

		@param CHAR type: 'D' or 'P'
		@param CHAR number: CHAR numeric representation of the owner
		@return BOOLEAN: to denote whether anything was printed
	*)
	PROCEDURE (dealer: DealerClassPointer) print*(type: CHAR; number: CHAR): BOOLEAN;
	VAR
		temp: Node;
		total: INTEGER;
	BEGIN
		temp := dealer.head;
		WHILE temp # NIL DO
			IF (temp^.owner[0] = type) & (temp^.owner[1] = number) THEN
				(* print cards contained *)				
				temp^.data^.print();
				
				(* print number of cards *)
				total := temp^.data^.count();
				Out.String("...");
				IF (total = 1) THEN
					Out.String(" 1 card"); ELSE Out.Int(total, 3); Out.String(" cards");
				END; Out.Ln;
				RETURN TRUE;
			END;
			temp := temp^.next;
		END;
		RETURN FALSE;
	END print;

	(*
		Prints out all the Lists that the dealer know of.

		@param void
		@return void
	*)
	PROCEDURE (dealer: DealerClassPointer) showLists*();
	VAR
		temp: Node;
	BEGIN
		temp := dealer.head;
		Out.String("Lists: ");
		WHILE temp # NIL DO
			Out.Char(temp^.owner[0]); Out.Char(temp^.owner[1]); Out.String(", ");
			temp := temp^.next;
		END;
		Out.Ln();
	END showLists;

	BEGIN

END DealerO.
