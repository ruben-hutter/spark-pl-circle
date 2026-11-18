# Anwendung: Batterie-Management-Firmware (BMS)

Nach dem Tutorial (Sprache) und der Schummel-Galerie (Spezifikations-
lücken): ein Stück Code, wie es in der Industrie tatsächlich in SPARK
geschrieben wird — nur stark vereinfacht und ohne Kanonen auf Spatzen.

Das Szenario: Ein E-Bike-Akku, 10 Zellen in Serie, 36 V nominell. Das
Paket `Bms` ist die Kernlogik der Firmware:

| Unterprogramm | Aufgabe | Tutorial-Kapitel, das man dafür braucht |
|---|---|---|
| `Total_Voltage` | Summe aller Zellspannungen | 4 (Schleifen/Invarianten) |
| `Charge_Protection` | Drosseln/Abschalten bei Grenzwerten | 3 (Contract_Cases) |
| `Raw_Charge_Level` | Coulomb-Zählung, Rohwert vor dem Klemmen | 1+3 (Bereiche, Pre) |
| `New_Charge_Level` | Ladestand, geklemmt auf 0 .. 1000 | 3 (Contract_Cases) |

Warum ausgerechnet das? Grenzwert- und Schutzlogik ist genau das, was
SPARK in Avionik, Flugsicherung und medizinischer Firmware macht: Werte
aus Sensoren kommen rein, Entscheidungen gehen raus, und NIEMALS darf
eine Rechnung überlaufen oder ein Zustand aus dem erlaubten Bereich
laufen — sonst zählt die Zellspannungs-Tabelle des BMS falsch und der
Akku brennt. Hier zählt im schlimmsten Fall ein Radcomputer falsch.

Beweisen wie gewohnt:

```bash
alr gnatprove -U --report=all
```

Der Ordner ist Teil des Hauptprojekts. In der Summen-Zeile taucht `Bms`
deshalb komplett grün auf — das Modul ist fertig bewiesen.

Was man beim Lesen beachten kann:

- Die Typen oben sind die Halbwahrheit der Hardware: Jeder Bereich steht
  in der Spezifikation, nicht im Kommentar. Das ist der Unterschied
  zwischen "dokumentiert" und "bewiesen".
- `Charge_Protection` entscheidet per Contract_Cases. Die Regeln (≥ 4150 mV
  oder ≥ 60 °C → aus; sonst > 15 A oder ≤ 2600 mV → drosseln) stehen
  nicht im Code, sondern im Kontrakt — der Code muss sie nur einhalten.
- Bei `New_Charge_Level` klemmt die Firmware den Ladestand an 0 und 1000.
  Genau dieses Klemmen ist im Contract_Cases-Post bewiesen — nicht nur
  "irgendwie im Bereich", sondern Fall für Fall.

Danach geht es weiter mit `vericoding/`: Dort schreiben nicht mehr du
diesen Code, sondern eine KI — und der Verifier auditet sie.
