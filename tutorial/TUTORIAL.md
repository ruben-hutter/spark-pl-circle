# SPARK-Tutorial

Fünf kurze Kapitel, jedes eine Datei in `tutorial/`. In jeder Datei steht oben
kurz das Wichtigste, darunter kleine Aufgaben mit `TODO`.

**Ziel pro Datei:** die Meldungen der Aufgaben verschwinden und alles ist grün.
Lösungen in `tutorial/loesungen/`.

Alle Aufgaben **ohne** `(optional)`-Vermerk reichen als Vorbereitung, die
optionalen Aufgaben sind Vertiefung für alle, die Zeit und Lust haben.

## So arbeitest du

Kapitel für Kapitel, in der Reihenfolge der Dateien. Pro Kapitel dieselbe
Schleife:

1. Befehl aus der Tabelle ausführen (Terminal im Projekt-Ordner).
2. **`medium:` / `high:`-Zeilen** = nicht bewiesen. Das sind deine Aufgaben.
3. Datei öffnen, an den `TODO`-Stellen arbeiten.
4. Befehl erneut — bis keine `medium:`/`high:`-Zeilen mehr kommen.
   Dann nächstes Kapitel.

| Kapitel | Datei | Befehl |
|---|---|---|
| Setup-Check | `tutorial/00_hello.ads` | `alr gnatprove -u hello --report=all` |
| 1 | `tutorial/01_types.adb` | `alr gnatprove -u types --report=all` |
| 2 | `tutorial/02_functions.ads` | `alr gnatprove -u functions --report=all` |
| 3 | `tutorial/03_contracts.ads` | `alr gnatprove -u contracts --report=all` |
| 4 | `tutorial/04_loops.ads` | `alr gnatprove -u loops --report=all` |
| 5 | `tutorial/05_run.adb` | `alr build`, dann `./bin/spark_pl_circle` |

Der Setup-Check muss ohne Aufgaben durchlaufen; Kapitel 5 ist primär bauen
und ausführen (Details dort). Unit ist der Package-Name der Datei, nicht der
Dateiname: aus `00_hello.ads` wird `hello` (klein geschrieben). Das Mapping
steht in `spark_pl_circle.gpr`, package `Naming` — deshalb funktioniert
Kapitel 5 auch mit `alr gnatprove -u run --report=all`.

**Am Schluss der Gesamtcheck**, alles auf einmal:

```bash
alr gnatprove -U --report=all
```

Mit `-u <unit>` beweist gnatprove die eine Unit und nimmt dabei die
Kontrakte der anderen Units als wahr an. Erst `-U` zeigt, dass alles
zusammenpasst. Wer nur wissen will, ob alles bewiesen ist: in der Tabelle am
Ende von `obj/gnatprove/gnatprove.out` (Pfad wird nach jedem Lauf genannt)
muss die Spalte `Unproved` leer sein.

Tipp fürs Terminal: TAB vervollständigt im Container auch `alr`-Befehle und
-Schalter. Alle gnatprove-Schalter (z.B. `--level`, `--prover`, `--timeout`)
zeigt `alr exec -- gnatprove --help` — `alr gnatprove --help` geht nicht,
alr fängt den Help-Schalter vorher ab.

Gut zu wissen:

- Behebe immer nur **einen** Fehler nach dem anderen: gnatprove nimmt
  frühere asserts als gegeben an, wenn es spätere beweist. Eine Zeile
  kann deshalb grün erscheinen, obwohl eine davor rot ist (Kapitel 2:
  die Is_Even-Tests sind "proved", solange der Square-assert davor rot
  ist). Erst wenn davor alles grün ist, sagt grün auch was.
- Bei harten Beweisen hilft `--level=2`: statt einem laufen dann drei Prover
  mit mehr Zeit, und als Bonus gibt's Gegenbeispiele (`e.g. when B = 0`).
  Stufen 0-4, höhere = mehr Aufwand.

---

## Typische Fehlermeldungen

Alle Zeilen der Tabelle sind echte Meldungen aus diesem Tutorial (fast alle von
gnatprove, eine Compiler-Warnung von `alr build`).

| Meldung | Häufige Ursache |
|---|---|
| `precondition might fail` | Aufrufer verletzt `Pre`; Vorbedingung verschärfen oder Aufrufer prüfen |
| `divide by zero might fail` | `Pre => B /= 0` (oder `B > 0`) fehlt |
| `overflow check might fail` | Rechnung kann überlaufen, weil ein Bereich fehlt (Pre, Subtyp oder Invariante) |
| `range check might fail` | Wert kommt nicht in den Subtyp (z.B. `Total : Percent_Sum := A + B`, wenn der Bereich von `Percent_Sum` zu klein ist) |
| `postcondition might fail` | Code falsch; oder `Post` fehlt bzw. ist zu schwach |
| `contract cases might not be complete` | Bei `Contract_Cases` fehlt ein Fall |
| `assertion might fail` | `pragma Assert` stimmt nicht, oder ein `Post` fehlt noch |
| `loop invariant might fail in first iteration` | Invariante gilt nicht in der ersten Runde |
| `loop invariant might not be preserved by an arbitrary iteration` | Schleifenkörper verletzt die Invariante |
| `loop variant might fail` | Zähler bewegt sich nicht (`C := C + 0`!) |
| `loop might be nonterminating` | `Always_Terminates` ist ohne `pragma Loop_Variant` nicht beweisbar |
| `"X" is not initialized` | Fluss-Analyse: Variable gelesen, nie gesetzt |
| `variable "X" is read but never assigned` | dazugehörige Compiler-Warnung bei `alr build` |
| `subprogram "P" has no effect` | harmlos: reines Rechenprogramm ohne Ausgabe |
| `cannot unroll loop (too many loop iterations)` | harmlos: Info-Meldung |
| `provers reached step limit before completing the proof` | Solver am Limit; `--level=2` (mehr Zeit) versuchen |

---

## Kapitel 1: Typen

`tutorial/01_types.adb`

```ada
subtype Percent is Integer range 0 .. 100;
procedure Ranges (A, B : Integer);  -- A und B: Eingaben, gnatprove kennt
                                    -- ihre Werte NICHT, nur den Typ
A in 0 .. 100            -- Membership-Test
X not in Percent         -- Negation
```

In SPARK hat **jeder Typ einen Bereich**, und gnatprove beweist zu jeder
Rechnung, dass der Bereich nie verletzt wird. Range-Subtypes absorbieren
dadurch viele Vorbedingungen (der Typ IST die Vorbedingung). Genau das
ist Aufgabe b1.

| Ausdruck | Bedeutung |
|---|---|
| `A (2)` | Array-Zugriff mit Klammern |
| `A'First`, `A'Last`, `A'Length` | erster/letzter Index, Länge |
| `X in Bereich` / `X not in Bereich` | enthalten / nicht enthalten |
| `for all I in A'Range => ...` | Quantor: für alle |
| `for some I in A'Range => ...` | Quantor: mindestens eins |

**Aufgaben a bis c** in der Datei, alle drei. Bei b) und c) reicht
Literal-Rechnen nicht mehr: A und B sind Eingaben, gnatprove kennt ihre
Werte nicht, nur den Typ. b) Welcher Typ beweist die asserts (b1)? Wie
gross wird `A + B` im schlimmsten Fall (b2, die `range check might
fail`-Meldung aus der Fehlertabelle oben tritt dort von selbst auf)?
c) Quantoren.

## Kapitel 2: Funktionen

`tutorial/02_functions.ads`

```ada
function Maximum (A, B : Small_Number) return Small_Number is
  (if A > B then A else B);   -- Expression Function: genau EIN Ausdruck
```

Expression Functions darf man in `pragma Assert` und in Spezifikationen verwenden.
Adas `mod` liefert bei positivem Teiler nie ein negatives Ergebnis:
`(-7) mod 2 = 1` (anders als `%` in C/Java).

Warum `Small_Number` statt `Integer`? Weil gnatprove bei jeder Funktion
**mitbeweist**, dass nichts überläuft. `2 * X` mit unbeschränktem `X`
wäre rot.

**Aufgaben a und b**: `Square`, `Is_Even` schreiben. Die
asserts am Ende beweisen, dass die Definitionen zu den Tests passen.

## Kapitel 3: Kontrakte

`tutorial/03_contracts.ads` und `.adb`

```ada
procedure Divide (A, B : Integer; Q : out Integer) with
  Pre  => B > 0,       -- Vorbedingung: Pflicht des Aufrufers
  Post => Q = A / B;   -- Nachbedingung: Versprechen für ALLE Eingaben
```

Wichtig: Der Aufrufer sieht **nur** Pre/Post (in der `.ads`-Datei), nie den
Code (in der `.adb`-Datei). Was nicht im Post steht, weiss der Aufrufer
nicht. Die Trennung sieht man hier physisch im Dateisystem. In `Post` sind
zwei Attribute erlaubt: `F'Result` (Rückgabewert) und `X'Old` (Wert beim
Eintritt).

Zwei SPARK-Momente:

- Selbst `Absolute_Value` braucht eine Vorbedingung: `-Integer'First` überläuft.
- Bei `Divide` reicht `B /= 0` nicht, denn `Integer'First / -1` überläuft
  ebenfalls (das Ergebnis `+2147483648` passt nicht in `Integer`).

`Contract_Cases` teilt das Post in mehrere Fälle auf: die Fälle
müssen sich **nicht überlappen** und **lückenlos** sein. (Mehrere
`Post =>`-Zeilen gibt es in Ada nicht; dafür ein Post mit mehreren Konjunkten.)

**Aufgaben a bis d** in der Datei. Am wichtigsten: **a** (das SPARK-Moment:
Overflow!) und **d** (`Contract_Cases`).
b und c sind optional.

## Kapitel 4: Schleifen

`tutorial/04_loops.ads` und `.adb`

```ada
S := 0;
for I in 1 .. N loop
   S := S + I;
   pragma Loop_Invariant (S = Sum (I));   -- geprüft: 1. Runde + nach jeder Runde
end loop;
```

gnatprove prüft die Invariante an ihrer Stelle: Sie muss in der **ersten
Runde** gelten und von jeder Runde **erhalten** werden (Meldung: `might
not be preserved`). Stehen darf sie am Anfang oder am Ende des
Loop-Körpers.

Nach der Schleife weiss gnatprove **nur** die Invarianten plus dass die
Bedingung falsch ist. Alles andere ist vergessen. Den Wert beim
Schleifeneintritt gibt es trotzdem noch: `X'Loop_Entry` (wie `X'Old`, nur
für den Schleifenstart).

Zwei Bemerkungen:

- Die `Sum`-Funktion ist die Gauss-Formel statt Rekursion: gnatprove müsste
  bei Rekursion mitbeweisen, dass das Ergebnis nie überläuft, und das
  braucht Induktion. Die Formel macht den Wert direkt berechenbar.
- **Terminierung ist nicht automatisch!** SPARK prüft Terminierung von
  Funktionen immer mit (daher die `info:`-Zeilen `implicit aspect
  Always_Terminates ... has been proved`), Prozeduren aber nur auf
  Verlangen: mit dem Aspect `Always_Terminates` am Unterprogramm, und
  `pragma Loop_Variant` in der Schleife macht den Beweis dann möglich.

**Aufgabe a**: Eine Invariante fehlt. Das Muster ist wie bei `Compute_Sum`.

**Optional:** die beiden `Ausprobieren`-Blöcke, inklusive das
Terminierungs-Experiment (`C := C + 1` zu `C := C + 0` ändern und die
Meldung anschauen, danach zurückändern).

## Kapitel 5: Ausführen

`tutorial/05_run.adb`

```bash
alr build                # übersetzen
./bin/spark_pl_circle    # ausführen
```

Ein Vergleich mit Dafny: Dort verschwindet die Spezifikation beim
Übersetzen (kostet zur Laufzeit nichts). In SPARK bleiben die Checks
**drin**: Range-, Overflow- und Division-Checks baut der Compiler immer ein;
Vor/Nachbedingungen und Asserts ebenfalls, allerdings erst mit dem Schalter
`-gnata`. Der Beweis garantiert: **sie schlagen nie fehl.** Du zahlst die
Spezifikation zur Laufzeit und kriegst dafür die Garantie, dass sie nie
fehlschlagen.

**Pflicht:** einmal `alr build` und ausführen, mehr ist hier nicht zu tun.

**Bonus: Fluss-Analyse.** Kommentiere den `declare`-Block am Ende ein und
führe beides aus: `alr build` und `alr gnatprove`. Fluss-Analyse ist neben
dem Beweisen der zweite Analyse-Modus von SPARK: schnell wie ein
Compilerlauf, prüft sie, dass keine Variable gelesen wird, bevor sie
initialisiert wurde, und dass die Datenflüsse stimmen (`Global`,
`Depends`).
