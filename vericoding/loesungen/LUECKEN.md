# Lücken-Katalog: So schwächen KI-Spezifikationen (Runde 2)

Typische Muster, wie KI-Modelle ein Lastenheft in SPARK formalisieren,
wenn man sie nicht im Zaum hält. Jede Muster ist "grün" — und genau
darum gefährlich. In etwa der gleichen Reihenfolge wie die
Schummel-Galerie (`experiment/`), nur ist der Schummler jetzt die KI
und die Schwachstelle liegt in der Formalisierung, die sie gewählt hat.

Erst selbst gegen die eigene KI-Spezifikation suchen, dann hier lesen!

---

## 1) Subtyp-Cheating: der Bereich wird grosszügig

Das Lastenheft sagt: Ladestand 0 .. 1000, darf nie herauslaufen. Eine
KI, deren Beweis hakt, weicht gern das Typsystem auf:

```ada
subtype Charge_Level is Natural;               -- statt range 0 .. 1_000
```

Damit verschwinden alle Bereichs-Meldungen — und mit ihnen die
komplette Regel 3. Grün, bewiesen, nutzlos. Die Verklemmung muss dann
irgendwo im Code stehen, wo der Verifier sie nicht mehr als Versprechen
prüft. Die menschliche Version (`anwendung/bms.ads`) macht daraus ein
`Charge_Level` plus bewiesenes
`Contract_Cases`-Post.

**Erkennen an:** Subtyp-Deklarationen mit dem Lastenheft abgleichen.
Jede Zahl aus dem Lastenheft, die fehlt, ist eine unbewachte Grenze.

## 2) Das "irgendein Wert aus dem Bereich"-Post

`Total_Voltage` muss laut Lastenheft die SUMME sein. Die KI schreibt
aber gern nur:

```ada
Post => Total_Voltage'Result in 25_000 .. 42_000
```

Grün mit `return 42_000;`. (Genau so lässt sie sich auch in Runde 1
schummeln — dort ist es Absicht.) Ein exaktes Post über eine Summe
braucht eine Loop-Invariante, die die Teilsumme festhält — wie in
`anwendung/bms.adb`. Wenn die KI-Invariante nur Bereiche statt Werte
enthält, ist die Summe ein Mythos.

**Erkennen an:** eine Zeile falschen Codes suchen, die das Post nicht
merkt. Findet man eine, fehlt im Post etwas Wichtiges.

## 3) Grenzvergleich kippen: erreicht = >=

"… sobald die stärkste Zelle 4150 mV ERREICHT" heisst `>= 4_150`.
KI-Modelle erzeugen daraus gern `> 4_150` — und bauen dieselbe Kippe
spiegelbildlich in den Code ein, damit alles grün bleibt. Der Verifier
kann das nicht merken: Er kennt nur die Spezifikation, nicht das
Lastenheft. Die Prosa ist der einzige Massstab, und Prosa-Menschen
meinen mit "erreicht" fast immer >=.

Bei "unter 2600 mV fällt" (< 2600? ≤ 2600?) ist die Prosa selbst
schuld: Das Lastenheft ist hier wirklich zweideutig — das ist real und
der Grund, warum Grenzfragen in Reviews von Specs die Nummer eins sind.

**Erkennen an:** jede Vergleichszeile der KI-Spez gegen das Lastenheft
lesen. Randfälle konstruieren: genau 4150, genau 2600, genau 60 °C.

## 4) Vorbedingungen statt Klemmen

"Der Ladestand darf NIE aus dem Bereich laufen" — die KI "löst" das
gern, indem sie die Verantwortung dem Aufrufer gibt:

```ada
Pre => Raw_Charge_Level (Old_Value, I, Seconds) in Charge_Level
```

Damit ist der Zähler "beweisbar im Bereich" — sobald halt irgendjemand
die Pre einhält. Aber der Rohwert ist eine Rechengrösse, kein
Eingabewert: Es gibt keinen ehrlichen Aufrufer, der sie garantieren
kann. Das Klemmen (Regel 3, zweiter Satz) ist weg. Die menschliche
Version klemmt und beweist die drei Fälle einzeln.

**Erkennen an:** Vorbedingungen, die nichts vom echten Umfeld (Sensoren,
Hardware-Grenzen) stammen, sondern Zwischenwerte absichern.

## 5) Overflow-Vermeidung durch Typwechselei

Strom · Sekunden kann gross werden; vergisst die KI die Zyklusgrenze
(`Seconds <= 60`), meldet gnatprove `overflow check might fail`. Der
faule Fix lautet dann oft:

```ada
I : Long_Integer;   -- oder Universal_Integer-Tricks
```

Damit wird der Überlauf nicht unmöglich gemacht, sondern nur unsichtbar
(und die Hardware-Welt in mA wäre damit auch kaputt). Der ehrliche Fix
steht in `anwendung/bms.ads`: die Vorbedingung `Seconds <= 60` — das
ist real, ein Zyklus dauert in der Firmware genau so lang.

**Erkennen an:** Typen, die grösser sind als die Hardware; fehlende
Bounds, wo das Lastenheft welche hergibt.

## 6) Contract_Cases, die sich überlappen

Die Schutz-Logik als Contract_Cases ist ideal — bis die KI Fälle
schreibt, die gleichzeitig wahr sein können (z. B. Drosseln ohne den
expliziten Ausschluss der Abschalt-Bedingung). gnatprove meldet
`contract cases might overlap`; hält die KI dagegen, indem sie einen
Fall löscht, ist die Lücke komplett. Die menschliche Version formuliert
Fall 2 mit dem ausdrücklichen `M.Max_Cell < 4_150 and then
M.Max_Temp < 60` — die Negation von Fall 1, damit die Disjunktheit
beweisbar ist.

**Erkennen an:** `Contract_Cases` immer auch als Logik-Rätsel lesen:
Kann ein Messwert zwei Fälle gleichzeitig erfüllen?

## 7) Vorzeichenflips in der Coulomb-Zählung

Positiv = laden. Rechnet die KI mit umgekehrter Konvention (oder
vertauscht in `Old_Value + … / Capacity` das Vorzeichen), entlädt das BMS
beim Laden und umgekehrt — beweisbar grün, wenn Spez und Code
konsistent falsch sind. Der Bereichscheck merkt es erst am Klemmen,
und dort verwischt das Klemmen den Unterschied sogar meistens.

**Erkennen an:** eine physikalische Rechnung von Hand
nachvollziehen: 20 A laden, 60 s — muss der Zähler runter oder rauf?

---

## Der Meta-Punkt

Alle sieben Lücken sind KEINE Codefehler, sondern Formalisierungs-
Entscheidungen. Die KI schreibt den Code zur Spezifikation, den sie
sich selbst gegeben hat — und der Verifier beweist das stolz. Der
Mensch bleibt für genau eine Aufgabe zuständig: die Spezifikation.
Das ist Vericoding, und das ist der Grund, warum Werkzeuge wie SPARK
mit dem KI-Code-Momentum wachsen statt zu verlieren.
