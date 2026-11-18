--  Kapitel 3: Kontrakte
--
--  Pre  = Vorbedingung: Pflicht des Aufrufers
--  Post = Nachbedingung: Versprechen der Methode, für ALLE Eingaben
--
--  Wichtig: Ein Aufrufer sieht nur Pre/Post (in dieser .ads-Datei), nie den
--  Code (in 03_contracts.adb). Was nicht im Post steht, weiss der Aufrufer nicht.
--  Aufgabe: Mach alles grün.

package Contracts
  with SPARK_Mode
is

   --  Beispiel (fertig): In SPARK braucht selbst Absolute_Value eine
   --  Vorbedingung!
   --  -Integer'First wäre ein Overflow (Integer'First = -2147483648, aber
   --  das positive Gegenstück +2147483648 passt nicht mehr in Integer).
   --  SPARK beweist, dass der Overflow-Check nie feuert, und verlangt
   --  dafür die Pre-Zeile.
   function Absolute_Value (X : Integer) return Integer
   with
     Pre  => X /= Integer'First,
     Post =>
       Absolute_Value'Result >= 0
       and then (Absolute_Value'Result = X or else Absolute_Value'Result = -X);

   --  a) Divide ist rot: gnatprove meldet "divide by zero might fail".
   --    Schritt 1: Ergänze EINE Pre-Zeile mit B /= 0.
   --    Schritt 2: Warum bleibt noch eine Overflow-Meldung?
   --               (Tipp: was ist Integer'First / -1? Verschärfe die
   --               Pre-Zeile so, dass BEIDES unmöglich wird.)
   procedure Divide (A, B : Integer; Q : out Integer)
   with Post => Q = A / B;
   --  Fussnote für C- und Java-Leute: "/" rundet gegen 0 (wie dort).
   --  Ada unterscheidet "rem" (Vorzeichen wie der linke Operand) und
   --  "mod" (bei positivem Teiler nie negativ).

   --  b) (optional) Is_Adult hat einen Bug. gnatprove zeigt dir, dass das Post nicht hält.
   --    Korrigiere den Code (in 03_contracts.adb, nicht das Post!).
   procedure Is_Adult (Age : Natural; Adult : out Boolean)
   with Post => Adult = (Age >= 18);

   --  c) (optional) Percent rechnet einen Anteil in Prozent um. Der Body
   --    (in der .adb) ist fertig und bleibt stehen. Ohne Kontrakte ist er
   --    nicht beweisbar, zwei Hürden: division by zero und ein Overflow
   --    im Zwischenergebnis Remaining * 100 (Resultat passt, die Rechnung
   --    nicht!). Ergänze Pre und Post, bis alles grün ist.
   --    Tipp: schränke die Eingaben ein (siehe Kapitel 1: der Typ/die
   --    Pre-Zeile IST die Absicherung).
   function Percent (Remaining, Maximum : Natural) return Natural;
   --  TODO c): with Pre => ..., Post => ...

   --  d) Contract_Cases: mehrere Fälle, die lückenlos sein müssen und sich
   --    nicht überlappen dürfen. Hier fehlt ein Fall. Ergänze ihn.
   procedure Sign (X : Integer; S : out Integer)
   with Contract_Cases => (X > 0 => S = 1, X = 0 => S = 0);
   --  TODO d): ergänze den fehlenden Fall

   procedure Client;

end Contracts;
