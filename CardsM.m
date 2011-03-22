(*----------------------------------------------------------------

	Card Module, encapsulates suit and rank.

----------------------------------------------------------------*)
MODULE CardsM;
	TYPE
		Card* =
			RECORD
				suit*: CHAR; (* H, C, D, S *)
				rank*: CHAR; (* A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K *)
			END;
	BEGIN
	
END CardsM.
