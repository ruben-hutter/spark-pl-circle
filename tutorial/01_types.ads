--  Kapitel 1: Typen
--
--  Ada-Typen haben Bereiche. `subtype Percent is Integer range 0 .. 100`
--  garantiert: Der Wert ist IMMER zwischen 0 und 100.
--  Der Compiler prüft das zur Laufzeit, gnatprove beweist: Der Check feuert nie.
--  Aufgabe: Probiere die TODO-Stellen aus: Ändere, schau, was rot wird,
--           und mach es wieder grün. Nie ein assert löschen oder abschwächen!

package Types with SPARK_Mode is

   --  Unterdrückt "subprogram ... has no effect" von gnatprove: Beide
   --  Prozeduren nutzen nur lokale Variablen, ändern also nichts
   --  ausserhalb. Die Asserts darin beweist gnatprove trotzdem.
   pragma Warnings (Off, "*has no effect");

   subtype Percent is Integer range 0 .. 100;

   procedure Variables;

   --  b1) A und B sind (noch) unbeschränkte Integer: Die asserts im Body
   --      sind dann nicht für jede Eingabe beweisbar. Welcher Typ passt?
   procedure Ranges (A, B : Integer);

end Types;
