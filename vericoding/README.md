# Vericoding: Die KI schreibt, der Verifier kontrolliert

Bisher warst du immer beide Seiten: Autor des Codes und Autor der
Spezifikation. Vericoding dreht das auf — so wie es die Industrie gerade
ausprobiert: Eine KI (Claude, ChatGPT, Copilot …) schreibt den Code.
SPARK beweist, ob sie deine Spezifikation einhält. Du liest keine 200
Zeilen Code gegenlesen, du liest einen Verifier-Bericht.

Der Punkt in einem Satz (aus der Schummel-Galerie, jetzt gegen eine KI
gespielt):

> Der Verifier audit den generierten Code gegen DEINE Spezifikation.
> Grün heisst nur: so gut wie dein Kontrakt. Ist der Kontrakt schwach,
> ist die Bestätigung schwach.

Der Ablauf ist immer derselbe Kreis:

    Spezifikation schreiben (der Mensch)
        → Code von der KI schreiben lassen
            → gnatprove
                → grün? fertig.
                → Meldungen zurück an die KI, wiederholen

Die gnatprove-Meldungen sind dabei das beste Material, das du der KI
geben kannst: exakte Datei, Zeile, Vermutung des Verifiers. Konkreter
als jede Fehlerbeschreibung eines Menschen.

Voraussetzung: irgendein Chat-Fenster (oder Copilot im Editor). Mehr
braucht es nicht — SPARK-Code ist plain text.

---

## Runde 1: Spezifikation von dir, Code von der KI  (~15 Min)

`runde1/bms.ads` ist fertig — der Batterie-Kontrakt aus `anwendung/`.
Sie darf nicht geändert werden. Dir fehlt `runde1/bms.adb`, und den
schreibt die KI.

1. Kopiere den Inhalt von `runde1/bms.ads` in die KI, zum Beispiel mit
   diesem Auftrag:

   > Hier ist eine SPARK-Paketspezifikation (Ada 2012, SPARK 2014).
   > Schreibe den passenden package body. Ändere nichts an der
   > Spezifikation. Der Code muss mit gnatprove beweisbar sein.

   Besser wird es, wenn du Kontext gibst ("gnatprove beweist
   Range- und Overflow-Checks, der Zellen-Feld-Summe brauchst du eine
   Loop-Invariante") — probier beide Varianten und vergleiche.

2. Speichere die Antwort als `runde1/bms.adb` (nur den package body,
   keine Markdown-Reste) und beweise:

   ```bash
   alr exec -- gnatprove -P vericoding/runde1/runde1.gpr --report=all
   ```

3. Jetzt der interessante Teil. Drei mögliche Ausgänge:

   - **Rot mit Meldungen** (`overflow check might fail`,
     `range check might fail`, `precondition might fail` …): kopiere
     die gnatprove-Ausgabe zurück an die KI — "Behebe diese Meldungen,
     ändere die Spezifikation nicht." Wiederholen bis grün.
   - **Grün, aber geschummelt**: die Spezifikation von
     `Total_Voltage` verlangt nur einen Bereich … findest du den
     Ein-Zeilen-Schummel, mit dem jede KI trotzdem grün wird? Genau
     das ist die Lektion: die Schwachstelle liegt in der Spezifikation,
     nicht im (KI-)Code.
   - **Grün und korrekt**: gut — aber wirklich korrekt ist es erst,
     wenn du es mit `loesungen/runde1/bms.adb` verglichen hast.

Die Lektion der Runde: "Grün" ist nie stärker als die Spezifikation.
Und der Verifier ist der einzige Prüfer, der eine KI nicht beeindruckt.

## Runde 2: Anforderungen von dir, Spezifikation UND Code von der KI  (~20 Min)

Jetzt bekommt die KI nicht mal mehr die Spezifikation — nur noch das
Lastenheft: `runde2/anforderungen.md`. Prosa, wie sie eine Hardware-
Abteilung schreibt. Genau hier beginnt echte Vericoding-Arbeit, denn
die KI muss jetzt *formalisieren* — und jede Formalisierung ist eine
Entscheidung, die man angreifen kann.

1. Gib der KI das Lastenheft, zum Beispiel:

   > Hier ist ein Lastenheft. Implementiere es als SPARK-Paket
   > (bms.ads mit Kontrakten + bms.adb). Alle Zusicherungen müssen mit
   > gnatprove beweisbar sein.

2. Speichere beide Dateien in `runde2/` (bms.ads und bms.adb) und
   beweise:

   ```bash
   alr exec -- gnatprove -P vericoding/runde2/runde2.gpr --report=all
   ```

3. Erst wenn alles grün ist, beginnt die eigentliche Aufgabe:
   **Finde den Schummel, der gegen die KI-Spezifikation grün bleibt.**
   Es gibt mindestens einen — typische Schwachstellen (und was die KI
   dabei oft macht) stehen in `loesungen/LUECKEN.md`. Erst stöbern,
   dann nachlesen!

4. Zum Schluss der Vergleich mit der menschlichen Version:
   `anwendung/bms.ads` und `loesungen/runde2/`. Was hat die KI anders
   formalisiert? Was ist verloren gegangen? Was ist besser geworden?

Poste deinen besten KI-Schummel in den Chat:

> KI-Spez-Zeile: …  Schummel-Code: …  Folge: …

---

## Warum ausgerechnet SPARK?

Bei Sprachen ohne Verifier audit die KI ihre eigene Arbeit — meistens
mit weiteren KI-Tests, die dieselben Annahmen teilen. SPARK hat einen
unabhängigen Prüfer: den Beweis. Er kennt keine Höflichkeit und keine
Träumereien — entweder die Eigenschaft gilt für ALLE Eingaben, oder es
steht eine Meldung da. Deshalb gilt: je mehr Code KI-Generatoren
liefern, desto wertvoller wird die Spezifikationsseite — und genau die
bleibt beim Menschen. (In SPARK kann man sie sogar zur Laufzeit
mitbauen lassen: die bewiesenen Checks sind Teil des Binärcodes, siehe
Tutorial-Kapitel 5.)

## Stolperfallen

- Die KI liefert Markdown-Codeblöcke mit (` ```ada `): nur den Code
  zwischen den Blöcken speichern, sonst mag gnatprove die Datei nicht.
- Fehlt in der KI-Antwort das `with SPARK_Mode`, wird der Body
  stillschweigend nicht verifiziert (Tutorial-Spickzettel) — grün wäre
  dann **Lügen**. Achte auf die Zeile `package body Bms with SPARK_Mode is`.
- Beweis hängt: `--level=2` probieren (Tutorial-Befehle).
- Die KI darf am Code drehen, bis er grün ist — aber sie darf nie die
  Spezifikation schwächen. In Runde 1 ist das verboten (Datei
  vorgegeben). In Runde 2 ist genau das die Aufgabe: die Schwächung
  finden.

## Lösungen

`loesungen/runde1/` — menschlicher, bewiesener Body zur Runde 1
(identisch mit `anwendung/bms.adb`).
`loesungen/runde2/` — Referenz dafür, wie eine gute KI-Antwort
aussehen könnte, plus `loesungen/LUECKEN.md`, der Katalog der
typischen Lücken in KI-Spezifikationen.

---

## Weiterführend: offizielles Material

Was ihr hier von Hand spielt, skaliert AdaCore industriell — „deterministic
trust“: die KI schreibt, deterministische Tools liefern die Evidenz.

- [Developing High-Integrity Software with AI](https://youtu.be/uJPgbne2yb8)
  (AdaCore-Video): KI-gestützte Entwicklung + formale Methoden
- [Using AI and Formal Methods to Build Software](https://www.adacore.com/blog/using-ai-and-formal-methods-to-build-software)
  (AdaCore-Blog): der Beweis als Oracle für KI-Agenten
- [GNAT Foundry: Intersection](https://github.com/AdaCore/gnat-foundry-intersection)
  (offizieller Demonstrator): ein KI-Agent bearbeitet eine Änderungsanfrage
  an einer bewiesenen Ampel-Steuerung — CONOPS bis Beweis, mit Bericht
