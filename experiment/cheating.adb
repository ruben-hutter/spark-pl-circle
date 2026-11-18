package body Cheating with SPARK_Mode is

   procedure Withdraw (Balance, Amount : Natural;
                       New_Balance : out Natural; Success : out Boolean) is
   begin
      if 0 < Amount and then Amount <= Balance then
         New_Balance := Balance - Amount;
         Success := True;
      else
         New_Balance := Balance;
         Success := False;
      end if;
   end Withdraw;

   function Index_Of (A : Integer_Array; X : Integer) return Integer is
   begin
      for I in A'Range loop
         if A (I) = X then
            return I;
         end if;
      end loop;
      return -1;
   end Index_Of;

end Cheating;
