# Zulassungs-Audit (optional)

Dateien: `experiment/avionics.ads` (Spezifikation) und
`experiment/avionics.adb` (Code).

Du bist Prüfer:in bei der (fiktiven) Zulassung einer Kleinflugzeug-Avionik:
genau dieses Package, eine Box im Cockpit. Der Hersteller wirbt:
„Alles SPARK, alles bewiesen." Stimmt nicht — **jedes der sechs
Unterprogramme ist rot, und jedes aus einem anderen Grund.** Genau die
Fehlerarten, die der SPARK-Verifier standardmässig findet.

**Ziel:** Diagnostiziere pro Fall, WARUM gnatprove meckert, und poste
deinen Fund im Chat:

> Fund N: Kategorie — Erklärung

Eine Kategorie pro Unterprogramm (ein Fall kann zwei Meldungen werfen —
dann gehören sie zur gleichen Ursache). Namen der Kategorien darfst du
frei wählen; es zählt, dass die Erklärung stimmt.

Prüfen:

```bash
alr gnatprove -u avionics --report=all
```

Alles, was motzt (`medium:`, `high:`, `warning:`), ist ein Fall. Die
Meldungen zu zitieren hilft beim Erklären. Fang an, wo du willst —
Fahrwerk, Klappen, Kurs, Höhe oder Sensoren.

---

### Zwei Arten von Meckern

- **Fluss-Analyse**: schneller als der Beweis, schaut nur, wie Werte
  durchs Unterprogramm fliessen — nie, welche Werte es sind
  (uninitialisiert gelesen, ineffektive Statements, Abhängigkeiten).
- **Beweis** (`medium:`, `high:`): Kontrakte und Checks gegen alle
  Eingaben. Die Meldung nennt oft ein Gegenbeispiel — die konkreten
  Werte, die den Check sprengen. Das ist der schnellste Weg zur Diagnose.

Und die Typen machen einen Teil der Arbeit gratis: `type Feet is range
0 .. 20_000` beweist alle Range-Checks auf diese Werte mit — niemand kann
eine Höhe ausserhalb des Typs hineinrechnen, ohne dass gnatprove rot wird.

Diagnosen und Fixes aller sechs Fälle in `loesungen/` — ein eigenes
Projekt, das komplett grün ist:

```bash
alr exec -- gnatprove -P experiment/loesungen/loesungen.gpr --report=all
```
