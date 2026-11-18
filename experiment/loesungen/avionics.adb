--  Lösungen zum Zulassungs-Audit: die gefixten Körper.
--  (Spec-Seite und Diagnosen: avionics.ads hier im Ordner.)

package body Avionics
  with SPARK_Mode
is

   --  Fund 1-Fix: Max initialisieren (0 ist in Knots enthalten, das
   --  Leer-Maximum ist also 0 und leere Felder sind mitgedeckt).
   function Max_Speed (S : Sensor_Array) return Knots is
      Max : Knots := 0;
   begin
      for I in S'Range loop
         if S (I) > Max then
            Max := S (I);
         end if;
      end loop;
      return Max;
   end Max_Speed;

   --  Fund 2-Fix: Tmp wird auch gelesen — jetzt ist es ein echter Tausch.
   procedure Swap_Course (Heading, Course : in out Degrees) is
      Tmp : Degrees;
   begin
      Tmp := Heading;
      Heading := Course;
      Course := Tmp;
   end Swap_Course;

   --  Fund 3: Code unverändert — der Fehler lag im Contract (avionics.ads).

   procedure Set_Gear (Down : Boolean) is
   begin
      Gear_Down := Down;
   end Set_Gear;

   --  Fund 4: Code unverändert — der Fehler lag in der Spec (avionics.ads).
   --  Merken: Der Körper ist derselbe geblieben, nur der Guard der
   --  Contract_Cases redet jetzt über den Eingang (Pos) statt über den
   --  Ausgangszustand (Flaps_Out), den der Code erst selbst setzt.

   procedure Extend_Flaps (Pos : in out Flap_Position) is
   begin
      if Pos /= Full then
         Pos := Full;
         Flaps_Out := True;
      else
         Flaps_Out := False;
      end if;
   end Extend_Flaps;

   --  Fund 5: Code unverändert — die fehlende Information steckt jetzt
   --  in der constant-Deklaration (avionics.ads).

   procedure Climb (Altitude : in out Feet) is
   begin
      if Altitude < 9_000 then
         Altitude := Altitude + 1_000;
      elsif Altitude >= Max_Altitude then
         Altitude := Max_Altitude;
      else
         Altitude := Altitude + 100;
      end if;
   end Climb;

   --  Fund 6-Fix: EINE Zeile Invariante — "in den bisherigen Runden war
   --  alles unter dem Limit" — reicht, und das quantifizierte Post ist
   --  beweisbar (Muster aus Kapitel 4/5).
   function First_Above (S : Sensor_Array; Limit : Knots) return Natural is
   begin
      for I in S'Range loop
         pragma
           Loop_Invariant (for all K in S'First .. I - 1 => S (K) <= Limit);
         if S (I) > Limit then
            return I;
         end if;
      end loop;
      return 0;
   end First_Above;

end Avionics;
