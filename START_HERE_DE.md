# Little16R in Sileo installieren

## 1. Quelle hinzufügen

Öffne **Sileo → Quellen → +** und füge diese Adresse hinzu:

**https://raimexlp.github.io/Little16R/**

Aktualisiere die Quellen und suche nach **Little16R**. Der Link zum GitHub-Quellcode
ist eine andere Adresse und wird nicht als Sileo-Quelle eingetragen.

## 2. Ersten Gerätetest vorbereiten

Das Paket ist für **Rootful-Jailbreaks** gebaut, zunächst für ein iPhone 7 mit
iOS 15.8.8. Der genaue Jailbreak und Tweak-Loader müssen dazu passen. Kläre vor
dem ersten Test auch, wie du den Tweak bei einem SpringBoard-Absturz wieder
deaktivierst oder entfernst. Entferne andere Gesten-Tweaks vor dem Test.

Der Build und die Paketprüfungen laufen erfolgreich. Die Funktion auf einem
iPhone ist bisher noch nicht bestätigt; auch die sichtbare Homebar ist offen.

## 3. Paket installieren

Wähle Little16R in Sileo aus, bestätige die Installation und führe anschließend
den angebotenen Respring aus. Es gibt kein Einstellungsmenü: Der Prototyp versucht
beim Laden in SpringBoard, die Gesten zu aktivieren.

Teste zuerst Home-Geste, App-Wechsler und Kontrollzentrum. Prüfe die Homebar
gesondert, auch innerhalb von Apps. Funktioniert etwas nicht, sind der genaue
Jailbreak, der Tweak-Loader und die `[Little16R]`-Meldungen im Systemlog hilfreich.

## Updates und direkter Download

Neue erfolgreiche Builds von `main` werden automatisch in der Paketquelle
veröffentlicht. Jeder Build bekommt eine eigene Versionsnummer, sodass Sileo
neue Pakete als Update erkennen kann. In Sileo gegebenenfalls die Quellen
aktualisieren, bevor du nach Updates suchst.

Die `.deb` gibt es zusätzlich beim jeweiligen GitHub-Actions-Lauf unter
**Artifacts → Little16R-rootful-alpha**. Nach dem Entpacken kannst du sie direkt
an Sileo übergeben. Diese Build-Artefakte bleiben 14 Tage verfügbar; die
veröffentlichten Paketdateien bleiben in der Quelle erhalten.

Weitere technische Informationen: [BUILD.md](BUILD.md).
Credits, Herkunft und Kontakt: [CREDITS.md](CREDITS.md).
