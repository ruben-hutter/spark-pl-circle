--  Der Code zur Spec in avionics.ads.
--  Absichtlich so gelassen wie vom Hersteller geliefert: jedes
--  Unterprogramm ist aus einem anderen Grund rot.

package body Avionics with SPARK_Mode is

   --  1) Maximum über das Sensor-Array suchen.
   function Max_Speed (S : Sensor_Array) return Knots is
      Max : Knots;
   begin
      for I in S'Range loop
         if S (I) > Max then
            Max := S (I);
         end if;
      end loop;
      return Max;
   end Max_Speed;

   --  2) Heading und Course tauschen. (Tut es das?)
   procedure Swap_Course (Heading, Course : in out Degrees) is
      Tmp : Degrees;
   begin
      Tmp     := Heading;
      Heading := Course;
      Course  := Heading;
   end Swap_Course;

   --  3) Fahrwerk gemäss Schalter stellen.
   procedure Set_Gear (Down : Boolean) is
   begin
      Gear_Down := Down;
   end Set_Gear;

   --  4) Klappen ausfahren: wer schon draussen ist, bleibt draussen.
   procedure Extend_Flaps (Pos : in out Flap_Position) is
   begin
      if Pos /= Full then
         Pos := Full;
         Flaps_Out := True;
      else
         Flaps_Out := False;
      end if;
   end Extend_Flaps;

   --  5) Steigflug: +1000 ft weit unten, +100 ft im Schlussanstieg,
   --     an der Decke wird gesättigt.
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

   --  6) Ersten Sensor über dem Limit suchen.
   function First_Above (S : Sensor_Array; Limit : Knots) return Natural is
   begin
      for I in S'Range loop
         if S (I) > Limit then
            return I;
         end if;
      end loop;
      return 0;
   end First_Above;

end Avionics;
