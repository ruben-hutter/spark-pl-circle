--  SCHUMMEL-GALERIE: Lücken, Beispiele und dichte Spezifikationen
--
--  Alle Schummeleien unten sind mit gnatprove getestet: grün gegen die
--  schwache Spezifikation aus experiment/cheating.ads, rot gegen die
--  dichte Spezifikation hier (und umgekehrt: die Schummeleien unten sind
--  grün gegen die schwache Spezifikation).
--
--  SPARK-Besonderheit: Rechen-Schummeleien wie "New_Balance := Balance +
--  1_000_000" oder "New_Balance := 0 + Balance - Amount" bleiben zwar oft
--  im Bereich, aber gnatprove beweist Range- und Overflow-Checks IMMER mit:
--  Wer schummelt, muss ohne falsche Rechnung schummeln.

package Cheating with SPARK_Mode is

   type Integer_Array is array (Natural range <>) of Integer;

   --  1) Withdraw: 3 Lücken
   --
   --  Lücke A: Die Bank muss nie auszahlen. Success := False ist immer erlaubt.
   --    New_Balance := Balance; Success := False;
   --    (Variante: nur Beträge bis 100 auszahlen)
   --
   --  Lücke B: Bei Ablehnung darf sich der Kontostand ändern.
   --    New_Balance := 0; Success := False;        -- Konto leeren
   --    (Balance + 1_000_000 ist hier oft rot, denn der Overflow-Check
   --     schlägt an. Schummeln geht also nur ohne Rechnung.)
   --
   --  Lücke C: Abbuchen, aber Success := False melden.
   --    New_Balance := Balance - Amount; Success := False;
   --    Das Geld ist weg, der Kunde glaubt, es hat nicht geklappt.
   --
   --  Die Lücke "negative Beträge = Einzahlung" gibt es hier nicht:
   --  Amount : Natural schliesst Negative aus; der Typ bewacht, was sonst
   --  die Spezifikation bewachen müsste.
   procedure Withdraw (Balance, Amount : Natural;
                       New_Balance : out Natural; Success : out Boolean) with
      Post => (if Success then New_Balance = Balance - Amount)          -- war schon da
        and then Success = (0 < Amount and then Amount <= Balance)      -- zu: A und C
        and then (if not Success then New_Balance = Balance);           -- zu: B

   --  2) Index_Of: 3 Lücken
   --
   --  Lücke A: Nie etwas finden. return -1 ist immer erlaubt.
   --    (Variante: nur die erste Hälfte durchsuchen)
   --
   --  Lücke B: Ein Index ausserhalb des Feldes ist erlaubt, weil die
   --    schwache Spezifikation nur "-1 oder irgendein Index ≥ -1" verspricht.
   --    return A'Last + 5;   -- auch bei leerem Feld
   --
   --  Lücke C: Nicht das erste, sondern irgendein Vorkommen.
   --    von hinten suchen
   function Index_Of (A : Integer_Array; X : Integer) return Integer with
      Post =>
        (Index_Of'Result = -1                                     -- zu: B
           or else (Index_Of'Result in A'Range
                      and then A (Index_Of'Result) = X))
        and then
        (if Index_Of'Result = -1                                  -- zu: A
         then (for all K in A'Range => A (K) /= X))
        and then
        (if Index_Of'Result in A'Range                            -- zu: C
         then (for all K in A'First .. Index_Of'Result - 1 => A (K) /= X));

end Cheating;
