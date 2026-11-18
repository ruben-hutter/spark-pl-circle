package body Loops with SPARK_Mode is

   --  Beispiel (fertig):
   procedure Compute_Sum (N : Natural; S : out Natural) is
   begin
      S := 0;
      for I in 1 .. N loop
         S := S + I;
         pragma Loop_Invariant (S = Sum (I));
      end loop;
   end Compute_Sum;

   procedure Compute_Count (N : Natural; C, D : out Natural) is
   begin
      C := 0;
      D := 0;
      while C < N loop
         pragma Loop_Variant (Increases => C);
         --  pragma Loop_Invariant (D = 2 * C);   --  a) Einkommentieren!
         C := C + 1;
         D := D + 2;
      end loop;
   end Compute_Count;

end Loops;
