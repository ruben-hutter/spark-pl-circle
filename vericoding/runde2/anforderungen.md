# Lastenheft: Batterie-Überwachung BMS (Hardware-Abteilung, Version 2.1)

Produkt: E-Bike-Akku, 10 Zellen in Serie, 36 V nominell, maximal 42 V.

Dieses Dokument ist alles, was du von der KI bekommst — formuliere es in
SPARK (Spezifikation + Code) und lasse es beweisen. Anleitung in
`vericoding/README.md` (Runde 2).

## Messgrössen

- Zellspannung: zwischen 2500 mV (leer) und 4200 mV (voll).
- Pack-Strom: ±30 A, gemessen in Milliampere. Positiv = laden,
  negativ = entladen.
- Temperatur: −40 °C bis +85 °C, gemessen am wärmsten Punkt.
- Eine Messung enthält: kleinste Zellspannung, grösste Zellspannung,
  Strom, Temperatur.
- Gesamt-Kapazität rund 14 Ah. Ein Promille Ladestand entspricht
  14 000 mA·s.

## Regeln

1. Die Gesamtspannung des Packs ist die Summe aller 10 Zellspannungen
   (also immer zwischen 25 000 und 42 000 mV).
2. Schutz-Logik, bei jeder Messung zu prüfen:
   - ABSCHALTEN, sobald die stärkste Zelle 4150 mV erreicht oder der
     wärmste Punkt 60 °C erreicht.
   - Sonst DROSSELN, wenn der Strom über 15 A liegt oder die schwächste
     Zelle unter 2600 mV fällt.
   - Sonst NORMAL.
3. Ladestand (SoC) in Promille: 0 = leer, 1000 = voll. Er wird per
   Coulomb-Zählung aktualisiert: Pro Zyklus von höchstens 60 Sekunden
   ändert er sich um Strom · Sekunden / 14 000 (Promille).
   Der Ladestand wird an 0 und 1000 geklemmt: Er darf NIE aus dem
   Bereich laufen.
