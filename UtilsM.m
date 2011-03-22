(*----------------------------------------------------------------

	Utilities Module, will convert a string to an INTEGER.

----------------------------------------------------------------*)
MODULE UtilsM;
	IMPORT Out;
	TYPE
		String* =
			RECORD
				chars*: ARRAY 2 OF CHAR;
			END;

	(*
		Convert a string of 2 characters into an integer.

		@param StringBlock
		@return INTEGER
	*)
	PROCEDURE toInt*(VAR string: String): INTEGER;
	VAR
		first: INTEGER;
		second: INTEGER;
	BEGIN
		first := ORD(string.chars[0]) - 48;
		second := ORD(string.chars[1]) - 48;
		IF (first >= 0) & (first <= 9) THEN
			IF (second >= 0) & (second <= 9) THEN
				RETURN (first * 10) + second;
			ELSE RETURN first;
			END;
		END;
		RETURN 0;
	END toInt;

END UtilsM.
