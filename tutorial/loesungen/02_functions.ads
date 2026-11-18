--  Kapitel 2: Funktionen
--
--  Eine Expression Function definiert eine Berechnung mit genau EINEM
--  Ausdruck:
--
--     function Name (A, B : Integer) return Integer is (if A > B then A else B);
--
--  Functions darf man in asserts und in Spezifikationen verwenden.
--  Aufgabe: Ergänze die Rümpfe bei TODO, bis alle asserts grün sind.

package Functions
  with SPARK_Mode
is

   --  Warum ein Bereich statt Integer? Ohne Bereich könnte 2 * X überlaufen.
   --  gnatprove beweist Range- und Overflow-Checks IMMER mit!
   subtype Small_Number is Integer range -1_000 .. 1_000;

   function Double (X : Small_Number) return Integer
   is (2 * X);

   --  if-then-else ist ein Ausdruck (wie ?: in Java)
   function Maximum (A, B : Small_Number) return Small_Number
   is (if A > B then A else B);

   --  a) Square soll X * X liefern.
   function Square (X : Small_Number) return Integer
   is (X * X);

   --  b) Is_Even soll true sein, wenn N gerade ist. Tipp: mod
   --    (Ada's mod ist auch bei negativen Zahlen nie negativ.)
   function Is_Even (N : Small_Number) return Boolean
   is (N mod 2 = 0);

   --  Tests: gnatprove beweist diese asserts, weil es die Definitionen kennt.
   pragma Assert (Double (4) = 8);
   pragma Assert (Maximum (3, 7) = 7 and Maximum (7, 3) = 7);
   pragma Assert (Square (5) = 25);
   pragma Assert (Is_Even (4));
   pragma Assert (not Is_Even (7));

end Functions;
