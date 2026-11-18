--  LÖSUNGEN ZUM ZULASSUNGS-AUDIT
--
--  Eigenes Projekt mit den gleichen Unit-Namen wie im Experiment.
--  Beweisen mit:
--
--    alr exec -- gnatprove -P experiment/loesungen/loesungen.gpr --report=all
--
--  Pro Fall: Diagnose (was gnatprove meldet und warum), Fehlerklasse
--  und Fix. Wo beides denkbar war, stehen beide Wege im Kommentar.
--  In dieser Datei ist jeweils der SPEC-Teil gefixt, in avionics.adb
--  der CODE-Teil — genau da, wo der Fehler lag.

package Avionics
  with SPARK_Mode
is

   type Feet is range 0 .. 20_000;
   type Knots is range 0 .. 1_000;
   type Degrees is range 0 .. 359;
   type Flap_Position is (Up, Approach, Full);

   type Sensor_Array is array (Positive range <>) of Knots;

   Gear_Down : Boolean := False;
   Flaps_Out : Boolean := False;

   subtype Service_Ceiling is Feet range 0 .. 15_000;

   --  Fund 5: INFORMATION FEHLT (Muster "Increase" im AdaCore-Kurs)
   --  gnatprove meldete:
   --     medium: postcondition might fail, cannot prove Altitude = Max_Altitude
   --  Warum: Max_Altitude war eine VARIABLE Global. gnatprove darf beim
   --  Beweis von Climb nur annehmen, was Typ/Pre hergeben — also jeden
   --  Wert aus 0 .. 15'000. Gegenbeispiel: Max_Altitude = 500 und
   --  Altitude = 600: Post verlangt 600 >= 500 => Altitude = 500, der
   --  Code rechnet aber 600 + 1'000. Der Code wurde für "steht auf
   --  15'000 ft" geschrieben, die Info stand nirgends.
   --  Fix A (hier): Max_Altitude constant machen — die Info steckt dann
   --         im Programm, und der Beweis geht durch.
   --  Fix B: Max_Altitude Variable lassen und Climb eine Pre geben,
   --         z. B.  Pre => Max_Altitude >= 9_000.
   --         (9_000 ist die Schwelle im Code: darunter wird pauschal
   --         +1'000 gerechnet — nur darüber wird gesättigt.)
   Max_Altitude : constant Service_Ceiling := 15_000;

   --  Fund 1: UNINITIALISIERT GELESEN (Fluss-Analyse)
   --  gnatprove meldete (zweimal, gleiche Ursache):
   --     medium: "Max" might not be initialized
   --  Warum: Max wurde im Body vor der Schleife nie initialisiert —
   --  schon der erste Vergleich S (I) > Max liest es, bevor je etwas
   --  zugewiesen wurde (bei leerem Feld sogar erst das return).
   --  Fehlerklasse: Bug im CODE. Fix im Body: Max initialisieren.
   --  (Kein Spec-Fix möglich: Der Fall ist reine Fluss-Analyse, das
   --  Post sagt ja nur, was gilt, wenn der Körper sauber fliesst.)
   function Max_Speed (S : Sensor_Array) return Knots;

   --  Fund 2: INEFFEKTIVES STATEMENT (Fluss-Analyse, Muster "Swap" im AdaCore-Kurs)
   --  gnatprove meldete:
   --     warning: unused initial value of "Heading"
   --  Warum: Tmp := Heading ist wirkungslos — Tmp wird nie gelesen.
   --  Deshalb "verliert" der Anfangswert von Heading seine einzige
   --  Verwendung, und die Fluss-Analyse meldet genau das. Dahinter
   --  steckt der echte Bug: Course := Heading weist Course seinen
   --  EIGENEN alten Wert zu — getauscht wird nichts.
   --  Fehlerklasse: Bug im CODE. Fix im Body: Course := Tmp.
   procedure Swap_Course (Heading, Course : in out Degrees);

   --  Fund 3: FALSCHER DEPENDS-CONTRACT (Fluss-Analyse)
   --  gnatprove meldete:
   --     medium: missing dependency "Gear_Down => Down"
   --     medium: incorrect dependency "null => Down"
   --  Warum: Der Code setzt Gear_Down := Down, der Contract behauptete
   --  aber  Gear_Down => null  (Endwert hängt von keinem Input ab) und
   --  zusätzlich  null => Down  (Down beeinflusst nichts). Beides ist
   --  das Gegenteil dessen, was der Körper tut.
   --  Fehlerklasse: Bug in der SPEC — der Code ist genau das, was ein
   --  Fahrwerksschalter tun soll. Fix hier: die wahre Abhängigkeit
   --  angeben. (Global => (...) wäre die grobere Variante desselben
   --  Contracts.)
   procedure Set_Gear (Down : Boolean)
   with Depends => (Gear_Down => Down);

   --  Fund 4: CONTRACT_CASES-GUARDS GELTEN BEIM EINTRITT (Muster
   --  "Incr_Until" im AdaCore-Kurs)
   --  gnatprove meldete:
   --     medium: contract case might fail   (Fall others => Pos = Pos'Old)
   --  Warum: Guards werden VOR dem Aufruf bewertet, mit den Werten beim
   --  EINTRITT. Flaps_Out ist beim Eintritt noch False (die Box fährt
   --  die Klappen ja erst AUS), also gilt der others-Fall: Pos =
   --  Pos'Old. Der Körper setzt Pos aber auf Full — Widerspruch. Der
   --  Fehler ist die SPEC: Sie redet über einen Ausgangszustand
   --  (Flaps_Out), den erst der Code selbst herstellt.
   --  Fix hier: Guard über den EINGANG nehmen, über Pos. (Gleichwertig:
   --  ein normales Post mit if-Ausdruck
   --     Post => (if Pos'Old /= Full then Pos = Full else Pos = Pos'Old)
   --  — dort bezieht sich 'Old ausdrücklich auf den Eintritt.)
   procedure Extend_Flaps (Pos : in out Flap_Position)
   with Contract_Cases => (Pos /= Full => Pos = Full, others => Pos = Pos'Old);

   --  Fund 5: siehe Max_Altitude oben.
   procedure Climb (Altitude : in out Feet)
   with
     Post =>
       (if Altitude'Old < Max_Altitude
        then Altitude > Altitude'Old
        else Altitude = Max_Altitude);

   --  Fund 6: INVARIANTE FEHLT (Muster "Find" im AdaCore-Kurs)
   --  gnatprove meldete:
   --     medium: postcondition might fail, cannot prove First_Above'Result in S'Range
   --  Warum: Nach der Schleife weiss gnatprove NUR die Invarianten und
   --  dass die Schleifenbedingung falsch ist — alles über die bisherigen
   --  Runden ist vergessen. Ohne Invariante kann das 0 des Durchfalls
   --  (nichts gefunden) nicht vom 0 eines verlorenen Schleifenwissens
   --  unterschieden werden. Der Fehler steckt im CODE (es fehlt eine
   --  Zeile), nicht in der Spec: Das Post ist genau richtig.
   --  Fix im Body: eine Loop-Invariante, die festhält, was die bisherigen
   --  Runden geleistet haben.
   --  (Zum Pre gegen Overflow aus dem Kurs: Dieses Find-Variant rechnet
   --  nicht — nur vergleichen und indizieren —, also gibt es hier nichts
   --  gegen Overflow zu sichern. Eine Summen-Variante bräuchte zusätzlich
   --  eine Pre, die die Anzahl Runden begrenzt, siehe Kapitel 4.)
   function First_Above (S : Sensor_Array; Limit : Knots) return Natural
   with
     Post =>
       (if (for all I in S'Range => S (I) <= Limit)
        then First_Above'Result = 0
        else
          First_Above'Result in S'Range
          and then S (First_Above'Result) > Limit);

end Avionics;
