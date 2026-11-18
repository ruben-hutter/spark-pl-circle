package body Bms with SPARK_Mode is

   --  1) Gesamtspannung. Die Invariante ist das "Nach jeder Runde gilt"
   --    aus Tutorial-Kapitel 4: Nach K-1 Runden liegt S zwischen der
   --    Summe von K-1 Minimal- und K-1 Maximalwerten. Am Ende (K = 11)
   --    ist das genau das Post. Nebenbei beweist die Invariante, dass
   --    S + Cells (K) niemals überläuft.
   function Total_Voltage (Cells : Voltage_Array) return Pack_Voltage is
      S : Pack_Voltage := 0;
   begin
      for K in 1 .. Cell_Count loop
         pragma Loop_Invariant
           (S in (K - 1) * Cell_Voltage'First
                .. (K - 1) * Cell_Voltage'Last);
         S := S + Cells (K);
      end loop;
      return S;
   end Total_Voltage;

   --  2) Schutz-Logik: der Code spiegelt die Contract_Cases-Aufzählung
   --    aus der Spezifikation 1:1. gnatprove beweist, dass jede Regel
   --    im Code dort landet, wo ihr Fall es verlangt.
   function Charge_Protection (M : Measurement) return Protection_State is
   begin
      if M.Max_Cell >= 4_150 or else M.Max_Temp >= 60 then
         return Shutdown;
      elsif M.I > 15_000 or else M.Min_Cell <= 2_600 then
         return Throttling;
      else
         return Normal;
      end if;
   end Charge_Protection;

   --  3) Coulomb-Zählung mit Klemmen. Die drei Contract_Cases-Fälle
   --    werden hier zu den drei if-Zweigen; gnatprove beweist, dass
   --    der Rohwert immer in genau den Zweig läuft, den sein Fall
   --    vorschreibt — und dass "New_Value := R" im else-Zweig den
   --    Bereichscheck von Charge_Level besteht.
   procedure New_Charge_Level
     (Old_Value : Charge_Level; I : Current; Seconds : Positive;
      New_Value : out Charge_Level)
   is
      R : constant Integer := Raw_Charge_Level (Old_Value, I, Seconds);
   begin
      if R < Charge_Level'First then
         New_Value := Charge_Level'First;   -- leer: klemmen bei 0
      elsif R > Charge_Level'Last then
         New_Value := Charge_Level'Last;    -- voll: klemmen bei 1000
      else
         New_Value := R;                    -- im Bereich: übernehmen
      end if;
   end New_Charge_Level;

end Bms;
