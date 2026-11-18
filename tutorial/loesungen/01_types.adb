package body Types with SPARK_Mode is

   procedure Variables is
      X : Integer := 5;
   begin
      X := X + 1;            -- Zuweisung ist :=
      pragma Assert (X = 6); -- Vergleich ist =

      --  a) 6 + 2 = 8.
      X := X + 2;
      pragma Assert (X = 8);
   end Variables;

   --  b1) Der Typ IST die Vorbedingung: Mit A, B : Percent gilt
   --      A in 0 .. 100 für JEDE Eingabe — kein Literal-Rechnen nötig.
   procedure Ranges (A, B : Percent) is
      --  b2) Schlimmster Fall: 100 + 100 = 200.
      subtype Percent_Sum is Integer range 0 .. 200;

      --  Elementtyp Percent: Damit ist "for all I => Score (I) in Percent"
      --  beweisbar (mit Integer-Elementen bliebe das rot).
      type Score_Array is array (1 .. 3) of Percent;
      Score : Score_Array := (10, 20, 30);
      Total : Percent_Sum := A + B;
   begin
      pragma Assert (A in 0 .. 100);
      pragma Assert (B in 0 .. 100);
      pragma Assert (A + B <= 200);

      pragma Assert (Total <= 200);

      --  Attribute von Feldern: 'First, 'Last, 'Length
      pragma Assert (Score'First = 1);
      pragma Assert (Score'Last = 3);
      pragma Assert (Score'Length = 3);
      pragma Assert (Score (2) = 20);  -- Indexierung mit Klammern

      --  c) JEDER Score-Wert liegt in Percent,
      --     MINDESTENS EIN Wert (die 10) liegt nicht in 15 .. 25.
      pragma Assert (for all I in Score'Range => Score (I) in Percent);
      pragma Assert (for some I in Score'Range => Score (I) not in 15 .. 25);
   end Ranges;

end Types;
