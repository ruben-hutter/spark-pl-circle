--  SCHUMMELN
--
--  Beide Unterprogramme sind korrekt programmiert und grün.
--  Aber ihre Spezifikationen haben Lücken. Jede hat MINDESTENS DREI
--  verschiedene Lücken.
--
--  Ziel: Ändere den Code (cheating.adb) so, dass er FALSCH ist, aber GRÜN
--        bleibt. Die Spezifikation (diese Datei!) darfst du nicht ändern.
--        Jede Lücke, die du findest, postest du in den Chat:
--        "Lücke: ...  Schummel-Code: ..."
--
--  Fang an, wo du willst.
--
--  SPARK-Besonderheit: gnatprove beweist Range- und Overflow-Checks
--  IMMER mit. Mit falschen Rechnungen (Balance + 1_000_000) kannst du
--  hier nicht schummeln: Der Check schlägt an.

package Cheating with SPARK_Mode is

   type Integer_Array is array (Natural range <>) of Integer;

   --  1) Geld abheben
   --    Gemeint ist: Ist genug Geld da, wird abgehoben und Success ist True.
   --    Sonst passiert nichts und Success ist False.
   --    (New_Balance kann gar nicht negativ werden: Natural! Was sonst
   --    eine extra Post-Zeile bräuchte, macht hier der Typ gratis.)
   procedure Withdraw (Balance, Amount : Natural;
                       New_Balance : out Natural; Success : out Boolean) with
      Post => (if Success then New_Balance = Balance - Amount);

   --  2) Position von X in einem Feld suchen
   --    Gemeint ist: Index des ERSTEN Vorkommens von X, oder -1, wenn X fehlt.
   --    Index_Of ((5, 7, 7), 7) = 1,   Index_Of ((5, 7, 7), 9) = -1
   function Index_Of (A : Integer_Array; X : Integer) return Integer with
      Post => Index_Of'Result >= -1                              -- -1 oder ein Index
        and then (if Index_Of'Result in A'Range                  -- zeigt auf X
                  then A (Index_Of'Result) = X);

end Cheating;
