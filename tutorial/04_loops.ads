--  Kapitel 4: Schleifen und Invarianten
--
--  Eine Invariante gilt in jeder Runde an ihrer Stelle: gnatprove prüft,
--  dass sie in der ersten Runde gilt und von jeder Runde erhalten wird:
--
--     pragma Loop_Invariant (S = Sum (I));
--
--  Nach der Schleife weiss gnatprove NUR: die Invarianten + die
--  Schleifenbedingung ist falsch. Alles andere ist vergessen.
--
--  Termination: SPARK prüft sie bei Prozeduren nur auf Verlangen, mit dem
--  Aspect Always_Terminates am Unterprogramm oder mit pragma Loop_Variant
--  in der Schleife (macht hier die Arbeit).

package Loops
  with SPARK_Mode
is

   --  Summe 1 + 2 + ... + N (Gauss-Summenformel).
   --  Warum nicht rekursiv? Weil gnatprove für die Rekursion
   --  auch beweisen müsste, dass das Ergebnis nie überläuft. Das braucht
   --  Induktion. Die Formel macht den Wert direkt berechenbar.
   function Sum (N : Natural) return Natural
   is (N * (N + 1) / 2)
   with Pre => N <= 1_000;

   --  Beispiel (fertig):
   --  Ausprobieren (optional) a): kommentiere die Invariante aus -> rot. Warum?
   --  Ausprobieren (optional) b): lösche die Pre-Zeile -> rot. Warum?
   procedure Compute_Sum (N : Natural; S : out Natural)
   with Pre => N <= 1000, Post => S = Sum (N);

   --  a) Es fehlt EINE Invariante in 04_loops.adb.
   --    Tipp: Schau dir Compute_Sum an, dazu die Fehlermeldung von gnatprove.
   procedure Compute_Count (N : Natural; C, D : out Natural)
   with Pre => N <= 1000, Post => C = N and D = 2 * N, Always_Terminates;
   --  Ausprobieren (optional): wenn a) grün ist, ändere "C := C + 1" zu "C := C + 0"
   --  und schau, was die Termination-Prüfung meldet.

end Loops;
