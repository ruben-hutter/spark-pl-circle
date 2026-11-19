# SPARK

SPARK ist eine Teilmenge von Ada mit eingebautem Verifier: Du schreibst Code
und Spezifikation zusammen, gnatprove beweist, dass beides zusammenpasst.
Das heisst: Im Programm kommt es nie zu Laufzeitfehlern (overflow, division
by zero, array index out of bounds), und der Code hält die Kontrakte ein.

Deduktive Verifikation für sicherheitskritische Software, im Einsatz von
Avionik über Flugsicherung und medizinischer Firmware bis zur E-Mobilität.

---

## Vorbereitung

Alles, was du vorher brauchst: Container starten und `tutorial/TUTORIAL.md`
durcharbeiten.

Wer mehr will (optional): `experiment/`, das Zulassungs-Audit. Du bist
Prüfer:in einer Kleinflugzeug-Avionik — jedes Unterprogramm rot aus
einem anderen Grund. Lösen optional, Spass garantiert.

1. Voraussetzungen
- [Docker](https://docs.docker.com/get-docker/)
- [VS Code](https://code.visualstudio.com/docs/devcontainers/containers)
  oder ein beliebiger Editor + Terminal

2. Repository klonen
```bash
git clone https://github.com/ruben-hutter/spark-pl-circle.git
```

3. Dev container bauen. Der erste Build lädt einmalig ca. 1 GB Werkzeugkette
   in das Image, danach ist jeder weitere Start sofort fertig.

   Guide für [VS Code](https://code.visualstudio.com/docs/devcontainers/containers)

4. Im dev container terminal prüfen:
   ```bash
   alr gnatprove --version
   ```
   Ausgabe `FSF 16.x` = alles bereit.

5. `tutorial/TUTORIAL.md` öffnen und Kapitel für Kapitel durcharbeiten.
   Alle Aufgaben ohne `(optional)`-Vermerk reichen als
   Vorbereitung, die optionalen Aufgaben sind Vertiefung.

   Setup-Check: die Datei `tutorial/00_hello.ads` muss grün sein:
   ```bash
   alr gnatprove -u hello --report=all
   ```
   Zeilen mit `medium:` oder `high:` sind nicht bewiesene Checks, also
   deine Aufgaben.

---

## Befehle

```bash
alr gnatprove -U --report=all          # alles verifizieren (auch die Fehler zeigen)
alr gnatprove -u hello --report=all    # nur ein Kapitel verifizieren
alr build                              # bauen
./bin/spark_pl_circle                  # ausführen
gnatformat -P spark_pl_circle.gpr -U --charset utf-8 --check   # Stil prüfen
gnatformat -P spark_pl_circle.gpr -U --charset utf-8           # Stil anwenden
```

`-U` = alle Units prüfen (ohne prüft gnatprove nur das Hauptprogramm).
`-u <unit>` = nur diese Unit prüfen. Unit-Namen der Kapitel: `hello`,
`types`, `functions`, `contracts`, `loops`, `run` (Datei `0X_name.ads` →
Unit `name`).
`--report=all` zeigt auch die bewiesenen Checks; ohne sie sieht man nur Fehler.

TAB-Vervollständigung für `alr` funktioniert im Container. Alle gnatprove-Optionen
zeigt `alr exec -- gnatprove --help` (`alr gnatprove --help` funktioniert nicht,
alr fängt den Help-Schalter vorher ab).

Die `alr …`-Befehle laufen im dev container wie auf dem Host: Auch die
Nix-DevShell (`nix develop`) stellt `alr` bereit — in derselben Version
(2.1.1) wie im Container.

Einzelnes Unterprogramm geht mit
`--limit-subp=00_hello.adb:3` (nur Dateiname, ohne `tutorial/`-Präfix).

Formatierung: Ada-Dateien folgen dem GNAT-Stil (3 Leerzeichen, Zeilen
bis 79 Zeichen); `gnatformat` ist der Kanon und ist im dev container
wie in der Nix-DevShell installiert. `--check` steigt mit Exit-Code 1
aus, wenn etwas unformatiert ist — gut für CI. Die `loesungen/`-Ordner
liegen außerhalb des Projekts und werden einzeln formatiert:
`gnatformat --charset utf-8 --no-project <datei>`.

---

## Editoren

Ada-Code in diesem Repo wird mit **3 Leerzeichen** eingerückt (GNAT-Stil);
die Konfiguration ist im Repo committet und greift automatisch:

- **VS Code**: Dev Container öffnen — oder ausserhalb des Containers die
  beiden in `.vscode/extensions.json` empfohlenen Extensions
  (`AdaCore.ada`, `EditorConfig.EditorConfig`) installieren. Tab/Einrückung
  sind über `.vscode/settings.json` vorkonfiguriert.
- **Neovim**: nichts zu tun, das eingebaute EditorConfig-Plugin wendet
  `.editorconfig` an.

Über die Basis-Einrückung hinaus entscheidet nicht die Hand, sondern
`gnatformat` (siehe Befehle): fortlaufende Zeilen, Umbrüche, Aspekte.

---

## Links

- [Intro to SPARK](https://learn.adacore.com/courses/intro-to-spark/index.html),
  AdaCores geführter Kurs
- [SPARK User's Guide](https://docs.adacore.com/spark2014-docs/html/ug/index.html),
  Referenz
- [adacore.com/languages/spark](https://www.adacore.com/languages/spark),
  Fallstudien: NVIDIA, Zenseact, Hillrom, Latitude …

## Links: SPARK und KI

Das Semesterthema in einem Satz: die KI schreibt, der Verifier beweist.
Wer das vertiefen will, findet offizielles Material von AdaCore:

- [Developing High-Integrity Software with AI](https://youtu.be/uJPgbne2yb8) (Video):
  wie KI-gestützte Entwicklung und formale Methoden zusammenpassen
- [Using AI and Formal Methods to Build Software](https://www.adacore.com/blog/using-ai-and-formal-methods-to-build-software)
  (Blog): „deterministic trust“ (der Beweis als Oracle für KI-Agenten)
- [GNAT Foundry: Intersection](https://github.com/AdaCore/gnat-foundry-intersection):
  offizieller Demonstrator, in dem ein KI-Agent eine Änderungsanfrage
  an einer bewiesenen Ampel-Steuerung bearbeitet, Ende-zu-Ende mit Bericht
