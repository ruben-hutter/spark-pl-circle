--  Kapitel 1: Typen (Lösung)
--
--  Ada-Typen haben Bereiche. `subtype Percent is Integer range 0 .. 100`
--  garantiert: Der Wert ist IMMER zwischen 0 und 100.
--  Der Compiler prüft das zur Laufzeit, gnatprove beweist: Der Check feuert nie.

package Types
  with SPARK_Mode
is

   subtype Percent is Integer range 0 .. 100;

   procedure Variables;

   --  b1) Statt Pre => A in 0 .. 100: Der Typ erledigt das.
   procedure Ranges (A, B : Percent);

end Types;
