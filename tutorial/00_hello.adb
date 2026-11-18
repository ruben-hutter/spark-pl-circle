package body Hello with SPARK_Mode is

   function Absolute_Value (X : Small_Number) return Integer is
   begin
      if X < 0 then
         return -X;
      else
         return X;
      end if;
   end Absolute_Value;

end Hello;
