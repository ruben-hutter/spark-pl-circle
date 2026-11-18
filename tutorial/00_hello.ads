--  Setup-Check: Diese Datei muss grün sein.
--
--  Im Terminal:   alr gnatprove -u hello --report=all
--
--  Warum Small_Number und nicht Integer? Das erklärt Kapitel 1. 😉

package Hello
  with SPARK_Mode
is

   subtype Small_Number is Integer range -1_000 .. 1_000;

   function Absolute_Value (X : Small_Number) return Integer
   with
     Post =>
       Absolute_Value'Result >= 0
       and then (Absolute_Value'Result = X or else Absolute_Value'Result = -X);

end Hello;
