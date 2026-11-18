--  Kapitel 1: Typen
--
--  Ada-Typen haben Bereiche. `subtype Percent is Integer range 0 .. 100`
--  garantiert: Der Wert ist IMMER zwischen 0 und 100.
--  Der Compiler prüft das zur Laufzeit, gnatprove beweist: Der Check feuert nie.
--  Aufgabe: Ändere die Zeilen mit TODO, bis alles grün ist.
--           Nie ein assert löschen oder abschwächen!

package body Types
  with SPARK_Mode
is

   procedure Variables is
      X : Integer := 5;
   begin
      X := X + 1;            -- Zuweisung ist :=
      pragma Assert (X = 6); -- Vergleich ist =

      --  a) Ändere die Zeile so, dass das assert stimmt.
      X := X + 1;   -- TODO
      pragma Assert (X = 8);
   end Variables;

   --  A und B kommen von "aussen": gnatprove kennt ihre Werte NICHT,
   --  nur ihren Typ. Literal-Rechnen reicht hier nicht mehr.
   procedure Ranges (A, B : Integer) is
      -- TODO b1)
      subtype Percent_Sum is Integer range 0 .. 100;   -- TODO b2)

      type Score_Array is array (1 .. 3) of Percent;
      Score : Score_Array := (10, 20, 30);
      Total : Percent_Sum :=
        A + B;      -- rot: overflow + range check might fail
   begin
      --  b1) Diese asserts sollen für JEDE Eingabe gelten. Mit unbeschränktem
      --      Integer sind sie rot. Welcher Typ macht sie beweisbar?
      --      (nicht vergessen: auch in 01_types.ads anpassen)
      pragma Assert (A in 0 .. 100);
      pragma Assert (B in 0 .. 100);
      pragma Assert (A + B <= 200);

      --  b2) Wie gross kann A + B im schlimmsten Fall werden?
      --      Ergänze oben den Bereich von Percent_Sum.
      pragma Assert (Total <= 200);

      --  Attribute von Feldern: 'First, 'Last, 'Length
      pragma Assert (Score'First = 1);
      pragma Assert (Score'Last = 3);
      pragma Assert (Score'Length = 3);
      pragma Assert (Score (2) = 20);  -- Indexierung mit Klammern

      --  c) Quantoren - das Dafny-Pendant zu forall/exists.
      --     1) JEDER Score-Wert liegt in Percent.
      --     2) MINDESTENS EIN Score-Wert liegt nicht in 15 .. 25.
      pragma Assert (for all I in Score'Range => Score (I) = 20);  -- TODO
      pragma Assert (for some I in Score'Range => Score (I) = 99); -- TODO
   end Ranges;

end Types;
