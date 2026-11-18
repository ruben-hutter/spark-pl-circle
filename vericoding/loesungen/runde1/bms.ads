--  LÖSUNG zu Vericoding Runde 1 — Spezifikation, unverändert aus
--  runde1/bms.ads übernommen (der Kontrakt war ja vorgegeben).
--  Der passende Body liegt neben dieser Datei (bms.adb).

package Bms with SPARK_Mode is

   --  Hardware-Fakten: 10 Zellen in Serie, 36 V nominell. Diese Zahlen
   --  stehen oben, weil alles Weitere darauf aufbaut.
   Cell_Count : constant := 10;

   --  Jeder Typ bekommt genau den Bereich, den die Hardware physikalisch
   --  hat. Das ist der SPARK-Trick aus Tutorial-Kapitel 1: der Typ IST
   --  die Vorbedingung. Eine Zellspannung von 5000 mV kann im Aufrufer
   --  gar nicht erst entstehen — der Aufruf wäre nicht beweisbar.
   subtype Cell_Voltage is Natural range 2_500 .. 4_200;     -- Millivolt
   subtype Pack_Voltage is Natural range 0 .. 42_000;        -- Millivolt
   subtype Current      is Integer range -30_000 .. 30_000;  -- mA, + = laden
   subtype Charge_Level is Natural range 0 .. 1_000;         -- Promille
   subtype Temperature  is Integer range -40 .. 85;          -- Grad Celsius

   --  Die Zellspannungen eines Messzyklus, Zelle 1 bis Zelle 10.
   type Voltage_Array is array (1 .. Cell_Count) of Cell_Voltage;

   --  Eine Messung: was der Sensor-Hub in einem Zyklus liefert.
   type Measurement is record
      Min_Cell : Cell_Voltage;   -- schwächste Zelle im Pack
      Max_Cell : Cell_Voltage;   -- stärkste Zelle im Pack
      I        : Current;        -- Pack-Strom, positiv = laden
      Max_Temp : Temperature;    -- wärmster Punkt im Pack
   end record;

   type Protection_State is (Normal, Throttling, Shutdown);

   --  Wie viele Milliampere-Sekunden einem Promille Ladestand entsprechen.
   --  (Gesamt-Kapazität rund 14 Ah: 1000 · 14_000 mA·s = 14 A · 1000 s.)
   Capacity : constant := 14_000;

   --  1) Gesamtspannung: die Summe aller 10 Zellspannungen.
   --    Das Post garantiert nur den physikalisch möglichen Bereich — es
   --    beweist also vor allem: kein Overflow, kein Bereichsfehler, egal
   --    welche Werte reinkommen. (Ein exaktes Post "Ergebnis = Summe der
   --    Zellen" bräuchte eine Ghost-Funktion über dem Feld; mehr dazu im
   --    Kurs "Intro to SPARK", Kapitel zur funktionalen Korrektheit.)
   function Total_Voltage (Cells : Voltage_Array) return Pack_Voltage with
     Post => Total_Voltage'Result
               in Cell_Count * Cell_Voltage'First
               .. Cell_Count * Cell_Voltage'Last;

   --  2) Schutz-Logik: entscheidet anhand einer Messung, was die Lade-
   --    Elektronik tun soll. Die drei Regeln stehen im Contract_Cases —
   --    dort sind sie für Aufrufer und gnatprove verbindlich: gnatprove
   --    beweist, dass die Fälle lückenlos sind, sich nicht überlappen
   --    und der Code sie einhält.
   function Charge_Protection (M : Measurement) return Protection_State with
     Contract_Cases =>
       ((M.Max_Cell >= 4_150 or else M.Max_Temp >= 60) =>
          Charge_Protection'Result = Shutdown,
        (M.Max_Cell < 4_150 and then M.Max_Temp < 60
           and then (M.I > 15_000 or else M.Min_Cell <= 2_600)) =>
          Charge_Protection'Result = Throttling,
        others =>
          Charge_Protection'Result = Normal);

   --  3) Ladestand zählen (Coulomb-Zählung): der Rohwert vor dem Klemmen
   --    ist Old_Value + Current · Seconds / Capacity. Er kann unter 0 oder
   --    über 1000 laufen — genau wie in echt, wo der Zähler am leeren
   --    (0) und vollen (1000) Akku anschlägt.
   --    Auch diese Expression Function braucht eine Vorbedingung: ohne
   --    die Obergrenze für Seconds könnte Current · Seconds überlaufen.
   function Raw_Charge_Level
     (Old_Value : Charge_Level; I : Current; Seconds : Positive) return Integer
   is (Old_Value + (I * Seconds) / Capacity)
   with Pre => Seconds <= 60;   -- ein Zyklus dauert höchstens 1 Minute

   --  Der Ladestand NACH dem Klemmen: bleibt der Rohwert im Bereich,
   --    wird er übernommen; sonst klemmt es an 0 (leer) oder 1000 (voll).
   procedure New_Charge_Level
     (Old_Value : Charge_Level; I : Current; Seconds : Positive;
      New_Value : out Charge_Level) with
     Pre  => Seconds <= 60,
     Contract_Cases =>
       ((Raw_Charge_Level (Old_Value, I, Seconds) in Charge_Level) =>
          New_Value = Raw_Charge_Level (Old_Value, I, Seconds),
        (Raw_Charge_Level (Old_Value, I, Seconds) > Charge_Level'Last) =>
          New_Value = Charge_Level'Last,
        (Raw_Charge_Level (Old_Value, I, Seconds) < Charge_Level'First) =>
          New_Value = Charge_Level'First);

end Bms;
