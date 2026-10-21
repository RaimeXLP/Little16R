# Little16R: erster Build

Diese ZIP enthält Quellcode für einen experimentellen Rootful-Prototyp.
Sie enthält keine installierbare `.deb`. Noch nicht auf einem iPhone getestet.

## 1. Dateien hochladen

ZIP entpacken. Den Inhalt des Ordners `Little16R` ins Hauptverzeichnis deines
GitHub-Repositories hochladen. Vorhandene README, Credits und Plan aktualisieren.
`Tweak.m`, `Makefile`, `control` und `Little16R.plist` müssen direkt im
Hauptverzeichnis liegen, nicht in einem zusätzlichen Unterordner `Little16R`.

Der Build braucht außerdem `.github/workflows/build.yml`. Falls der Ordner
beim Hochladen nicht sichtbar ist, kannst du diese Datei auf GitHub über
**Add file → Create new file** unter genau diesem Namen anlegen und ihren
vollständigen Inhalt aus der ZIP einfügen.

## 2. Build starten

Unter **Actions → Build rootful prototype → Run workflow** manuell starten.
Falls GitHub die Aktivierung von Actions verlangt, aktiviere sie für dieses Repo.

Der Workflow baut und prüft das Paket. Er erstellt keine Commits und verändert
keine Dateien im Repository. Es kommt dadurch kein zusätzlicher Commit-Autor hinzu.

## 3. Ergebnis prüfen

Bei einem erfolgreichen Durchlauf liegt unter **Artifacts** ein Download namens
`Little16R-rootful-alpha`. Darin befindet sich die `.deb`.

Bei einem Fehler bitte den fehlgeschlagenen Schritt oder dessen Log weitergeben.
Ein erfolgreicher Build bedeutet noch nicht, dass die Gesten auf iOS 15.8.8 laufen.

Vor der Installation müssen Jailbreak und Tweak-Loader feststehen, einschließlich
eines funktionierenden Weges zum Deaktivieren von Tweaks bei einem SpringBoard-Absturz.
Der Prototyp hat kein Einstellungsmenü und versucht beim Laden, die Gesten zu aktivieren.
Die sichtbare Homebar, besonders innerhalb von Apps, ist noch unbestätigt.

Weitere technische Informationen: [BUILD.md](BUILD.md).
