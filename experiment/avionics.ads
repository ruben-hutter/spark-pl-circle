--  ZULASSUNGS-AUDIT
--
--  Du bist Prüfer:in bei der (fiktiven) Zulassung einer Kleinflugzeug-
--  Avionik: genau dieses Package, EINE Box im Cockpit. Der Hersteller
--  wirbt: „Alles SPARK, alles bewiesen.“
--
--  Stimmt nicht. gnatprove meldet für JEDES Unterprogramm etwas — und
--  zwar jedes Mal aus einem ANDEREN Grund. Das sind genau die sechs
--  Standard-Fehlerarten, die der Verifier findet (Fluss-Analyse und
--  Beweis, wie im AdaCore-Kurs "Introduction to SPARK").
--
--  Ziel: Diagnostiziere jeden Fall — WARUM meckert gnatprove? — und
--        poste deinen Fund im Chat:    Fund N: Kategorie — Erklärung
--        An dieser Datei (der Spec) nichts ändern: nur lesen.
--
--  Prüfen mit:
--     alr gnatprove -u avionics --report=all
--
--  Alles, was motzt (medium:, high:, warning:), ist ein Fall. Die
--  Meldungen zu zitieren hilft beim Erklären.

package Avionics
  with SPARK_Mode
is

   --  Schöne SPARK-Typen: Bereiche statt Integer. Jeder Bereich ist ein
   --  gratis Beweis — Range-Checks auf diese Werte feuern nie (Kapitel 1).
   type Feet is range 0 .. 20_000;
   type Knots is range 0 .. 1_000;
   type Degrees is range 0 .. 359;
   type Flap_Position is (Up, Approach, Full);

   type Sensor_Array is array (Positive range <>) of Knots;

   --  Zustand der Box (Globals, alle initialisiert):
   Gear_Down : Boolean := False;
   Flaps_Out : Boolean := False;

   --  Dienstgipfelhöhe: maximal 15'000 ft, laut Datenblatt 15'000 ft.
   subtype Service_Ceiling is Feet range 0 .. 15_000;
   Max_Altitude : Service_Ceiling := 15_000;

   --  1) Pitot-Statik: die höchste gemessene Geschwindigkeit aller
   --    Sensoren. (Klassiker der Fluss-Analyse.)
   function Max_Speed (S : Sensor_Array) return Knots;

   --  2) Kurskorrektur: aktueller Kurs und Sollkurs sollen tauschen.
   procedure Swap_Course (Heading, Course : in out Degrees);

   --  3) Fahrwerk: einfahren/ausfahren gemäss Schalter. Der Depends-
   --    Contract behauptet: der Endwert von Gear_Down hängt von
   --    keinem Input ab, und der Schalter beeinflusst nichts.
   procedure Set_Gear (Down : Boolean)
   with Depends => (Gear_Down => null, null => Down);

   --  4) Landeklappen ausfahren. Contract_Cases sagt: wenn die Klappen
   --    draussen sind, steht Pos danach auf Full — sonst unverändert.
   procedure Extend_Flaps (Pos : in out Flap_Position)
   with Contract_Cases => (Flaps_Out => Pos = Full, others => Pos = Pos'Old);

   --  5) Steigflug: Höhe erhöhen, an der Dienstgipfelhöhe sättigen.
   procedure Climb (Altitude : in out Feet)
   with
     Post =>
       (if Altitude'Old < Max_Altitude
        then Altitude > Altitude'Old
        else Altitude = Max_Altitude);

   --  6) Übergeschwindigkeit: Index des ersten Sensors über dem Limit,
   --    0 falls keiner. (Das Post ist quantifiziert — Schleifen-Sache.)
   function First_Above (S : Sensor_Array; Limit : Knots) return Natural
   with
     Post =>
       (if (for all I in S'Range => S (I) <= Limit)
        then First_Above'Result = 0
        else
          First_Above'Result in S'Range
          and then S (First_Above'Result) > Limit);

end Avionics;
