package body Contracts with SPARK_Mode is

   function Absolute_Value (X : Integer) return Integer is
   begin
      if X < 0 then
         return -X;
      else
         return X;
      end if;
   end Absolute_Value;

   procedure Divide (A, B : Integer; Q : out Integer) is
   begin
      Q := A / B;
   end Divide;

   procedure Is_Adult (Age : Natural; Adult : out Boolean) is
   begin
      Adult := Age >= 18;   --  b) Bug war: "Age > 18"
   end Is_Adult;

   function Percent (Remaining, Maximum : Natural) return Natural is
   begin
      return (Remaining * 100) / Maximum;
   end Percent;

   procedure Sign (X : Integer; S : out Integer) is
   begin
      S := (if X > 0 then 1 elsif X = 0 then 0 else -1);
   end Sign;

   procedure Client is
      Y : Integer;
      Q : Integer;
      S : Integer;
   begin
      Y := Absolute_Value (-5);
      pragma Assert (Y = 5);

      Divide (10, 2, Q);
      pragma Assert (Q = 5);

      pragma Assert (Percent (1, 3) in 0 .. 100);  --  (1 * 100) / 3 = 33, "/" rundet ab

      Sign (7, S);
      pragma Assert (S = 1);
   end Client;

end Contracts;
