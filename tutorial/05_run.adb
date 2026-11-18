--  Kapitel 5: Ausführen
--
--  Verifizieren und bauen sind zwei verschiedene Schritte:
--
--     alr gnatprove --report=all        -- beweisen
--     alr build                         -- übersetzen
--     ./bin/spark_pl_circle             -- ausführen
--
--  Der Beweis kauft dir: Alle Range-, Overflow- und Division-Checks
--  im Binary können nie feuern (und die Fluss-Analyse garantiert:
--  nichts wird uninitialisiert gelesen).

with Ada.Text_IO;

procedure Run with SPARK_Mode is

   function Sum (N : Natural) return Natural
   is (N * (N + 1) / 2)
   with Pre => N <= 1_000;

   procedure Compute_Sum (N : Natural; S : out Natural)
   with Pre => N <= 1000, Post => S = Sum (N)
   is
   begin
      S := 0;
      for I in 1 .. N loop
         S := S + I;
         pragma Loop_Invariant (S = Sum (I));
      end loop;
   end Compute_Sum;

   S : Natural;

begin
   Compute_Sum (10, S);
   Ada.Text_IO.Put_Line ("Summe 1..10 =" & Natural'Image (S));

--  Bonus: Fluss-Analyse (der zweite Analyse-Modus von SPARK neben dem
--  Beweisen). Einkommentieren und beides ausführen:
--    alr build      -> warning: variable "X" is read but never assigned
--    alr gnatprove  -> high: "X" is not initialized
--
--  declare
--     X : Integer;
--  begin
--     Ada.Text_IO.Put_Line (Integer'Image (X));
--  end;
end Run;
