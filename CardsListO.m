(*----------------------------------------------------------------

	CardsList Class, encapsulates cards in a list.

----------------------------------------------------------------*)
MODULE CardsListO;
	IMPORT Out, CardsM, RandomizerM;
	TYPE
		Card* = CardsM.Card; (* an individual list item *)

		(* internal nodes structure *)
		Node* = POINTER TO NodeBlock;
		NodeBlock =
			RECORD
				data*: Card;
				next*: Node;
			END;

		(* class definition *)
		ListClassPointer* = POINTER TO ListClass;
		ListClass* =
			RECORD
				head*: Node;
			END;

	(*
		Add a card to the head of the list.

		@param CHAR suit: H, C, D, S
		@param CHAR rank: A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
		@return void
	*)
	PROCEDURE (list: ListClassPointer) addCard*(suit: CHAR; rank: CHAR);
	VAR
		temp: Node;
		tempCard: CardsM.Card;
	BEGIN
		NEW(temp);
		temp^.next := list^.head;

		tempCard.suit := suit;
		tempCard.rank := rank;

		temp^.data := tempCard;
		list^.head := temp;
	END addCard;

	(*
		Discard a card from the head of the list (LIFO) and return it (as cards don't get lost).

		@param void
		@return Card: a card that we have discarded from the head.
	*)
	PROCEDURE (list: ListClassPointer) disCard*(): Node;
	VAR
		temp: Node;
		discardedCard: Node;
	BEGIN
		discardedCard := list.head;
		
		temp := list.head;
		IF (temp # NIL) THEN
			temp := temp^.next;
			list.head := temp;
		END;
		RETURN discardedCard;
	END disCard;

	(*
		Print a the cards contained in the form '[H 2]'.

		@param void
		@return void
	*)
	PROCEDURE (list: ListClassPointer) print*();
	VAR
		temp: Node;
	BEGIN
		temp := list.head;
		WHILE temp # NIL DO
			Out.Char("["); Out.Char(temp^.data.suit); Out.Char(" "); Out.Char(temp^.data.rank); Out.String("] ");
			temp := temp^.next;
		END;
	END print;

	(*
		Get the number of cards in this list.

		@param void
		@return INTEGER: number of Nodes contained
	*)
	PROCEDURE (list: ListClassPointer) count*(): INTEGER;
	VAR
		temp: Node;
		count: INTEGER;
	BEGIN
		temp := list.head;
		count := 0;
		WHILE temp # NIL DO
			count := count + 1;
			temp := temp^.next;
		END;
		RETURN count;
	END count;

	(*
		Shuffle cards in the deck by swapping values, not nodes :).

		@param void
		@return void
	*)
	PROCEDURE (list: ListClassPointer) shuffle*();
	VAR
		swapNode: Node;
		withNode: Node;
		withCounter: INTEGER;
		temp: ARRAY 2 OF CHAR;
		random: INTEGER;
	BEGIN
		swapNode := list.head;
		WHILE swapNode # NIL DO
			(* swap this card... *)
			temp[0] := swapNode^.data.suit; temp[1] := swapNode^.data.rank;
			random := RandomizerM.randomInt(); (* generate random number from a range of 52 *)

			(* do the swap *)
			withCounter := 0;
			withNode := list.head;
			WHILE withNode # NIL DO
				IF (withCounter = random) THEN
					swapNode^.data.suit := withNode^.data.suit;
					swapNode^.data.rank := withNode^.data.rank;
					withNode^.data.suit := temp[0]; withNode^.data.rank := temp[1];
				END;

				withCounter := withCounter + 1;
				withNode := withNode^.next;
			END;

			swapNode := swapNode^.next;
		END;
	END shuffle;

	BEGIN

END CardsListO.
