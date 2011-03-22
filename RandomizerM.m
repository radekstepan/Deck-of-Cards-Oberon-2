(*----------------------------------------------------------------

	Randomizer Module, will return a random number from a range.

----------------------------------------------------------------*)
MODULE RandomizerM;
	IMPORT Out, Random;

	VAR
		random: INTEGER;

	(*
		Return a random number from a range.

		@param void
		@return void
	*)
	PROCEDURE randomInt*(): INTEGER;
	BEGIN
		REPEAT random := randomBounded();
		UNTIL random < 52; (* just to make sure *)
		RETURN random;
	END randomInt;

	(*
		Will return a pseudo-randomly chosen number in the range 0-51.

		@param void
		@return INTEGER: random number in the 0-51
	*)
	PROCEDURE randomBounded(): INTEGER;
	BEGIN
		(* special brew *)
		random := ABS(ENTIER((SHORT(Random.Random()))/620));
		RETURN random;
	END randomBounded;

END RandomizerM.
