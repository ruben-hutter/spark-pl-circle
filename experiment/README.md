# Schummel-Galerie (optional)

Dateien: `experiment/cheating.ads` (Spezifikation) und
`experiment/cheating.adb` (Code). Zwei Unterprogramme: `Withdraw`
(Geld abheben) und `Index_Of` (in einem Feld suchen).

Beide sind korrekt programmiert und grün. Ihre Spezifikationen haben aber
**jeweils mindestens drei verschiedene Lücken**.

**Ziel:** Ändere den Code (`cheating.adb`) so, dass er falsch ist, aber
grün bleibt. Die Spezifikation (`cheating.ads`) darfst du nicht ändern.
Jede Lücke, die du findest, postest du in den Chat:

> Lücke: ...  Schummel-Code: ...

Prüfen nach jeder Schummelei:

```bash
alr gnatprove -U --report=all
```

Fang an, wo du willst.

---

### SPARK-Besonderheit

gnatprove beweist Range- und Overflow-Checks **immer mit**: Mit falschen
Rechnungen schummeln (`New_Balance := Balance + 1_000_000`) fällt sofort
auf. Wer schummeln will, muss ohne falsche Rechnung schummeln. (Und was
ein `New_Balance >= 0` in der Spezifikation wäre, macht hier der Typ
`Natural` von allein.)

Die Lücken liegen deshalb auf einer anderen Ebene, und zwar genau dort, wo
auch echte Spezifikations-Bugs liegen. Das ist der Punkt: Der Verifier
auditiert den generierten Code gegen DEINE Spezifikation. Ist die
Spezifikation schwach, findet er genau diese Schwäche.

Alle Lücken mit Beispielen und dichter Spezifikation in `loesungen/`.
