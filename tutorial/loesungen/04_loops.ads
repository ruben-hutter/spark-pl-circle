--  Kapitel 4: Schleifen und Invarianten (Lösung)

package Loops
  with SPARK_Mode
is

   function Sum (N : Natural) return Natural
   is (N * (N + 1) / 2)
   with Pre => N <= 1_000;

   procedure Compute_Sum (N : Natural; S : out Natural)
   with Pre => N <= 1000, Post => S = Sum (N);

   --  a) Invariante ergänzt.
   procedure Compute_Count (N : Natural; C, D : out Natural)
   with Pre => N <= 1000, Post => C = N and D = 2 * N, Always_Terminates;

end Loops;
