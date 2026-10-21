# Little16R in Sileo installieren

## 1. Quelle hinzufügen

Öffne **Sileo → Quellen → +** und füge diese Adresse hinzu:

**https://raimexlp.github.io/little16r/**

Du kannst die Seite auch direkt auf dem iPhone öffnen und auf **Zu Sileo
hinzufügen** tippen. Dort gibt es außerdem Buttons für Cydia, Zebra, Installer
und Saily sowie **Adresse kopieren**. Der jeweilige Paketmanager muss installiert
sein. Einträge mit der bisherigen Adresse `/Little16R/` bitte durch die neue,
vollständig kleingeschriebene Adresse ersetzen.

Aktualisiere die Quellen und suche nach **Little16R**. Der Link zum GitHub-Quellcode
ist eine andere Adresse und wird nicht als Sileo-Quelle eingetragen.

## 2. Ersten Gerätetest vorbereiten

Das Paket ist für **Rootful-Jailbreaks** gebaut, zunächst für ein iPhone 7 mit
iOS 15.8.8. Der genaue Jailbreak und Tweak-Loader müssen dazu passen. Kläre vor
dem ersten Test auch, wie du den Tweak bei einem SpringBoard-Absturz wieder
deaktivierst oder entfernst. Entferne andere Gesten-Tweaks vor dem Test.

Der erste Prototyp wurde bereits über Sileo auf Leons iPhone installiert.
Die neue optionale Homebar und das Einstellungsmenü müssen noch am Gerät geprüft
werden; ein erfolgreicher Build allein bestätigt diese Funktionen nicht.

## 3. Paket installieren

Wähle Little16R in Sileo aus und bestätige die Installation. Am Ende fordert das
Paket über Sileos Installationsabschluss einen Respring an. Tippe auf
**SpringBoard neu starten / Respring**. Sileo führt den Neustart aus.

Falls du einen älteren Build ohne diese Aufforderung installiert hast:
Aktualisiere in Sileo die Quellen und aktualisiere anschließend Little16R auf
die neueste Version. Nach diesem Update wird der Respring angefordert. Ist die
neueste Version bereits installiert, kannst du sie über **Ändern → Erneut
installieren** nochmals installieren, um die Abschlussaktion zu erhalten.

Die Wischgesten werden beim Laden in SpringBoard aktiviert. Die sichtbare
Homebar ist ab Version `0.2.0-alpha1` standardmäßig **aus**.

Teste zuerst Home-Geste, App-Wechsler und Kontrollzentrum. Prüfe die Homebar
gesondert, auch innerhalb von Apps. Funktioniert etwas nicht, sind der genaue
Jailbreak, der Tweak-Loader und die `[Little16R]`-Meldungen im Systemlog hilfreich.

## 4. Homebar bei Bedarf einschalten

1. Öffne **Einstellungen → Little16R**. Falls Einstellungen beim Update offen war,
   schließe die App im App-Wechsler und öffne sie erneut.
2. Schalte **Homebar anzeigen** ein oder aus.
3. Tippe auf **Übernehmen & Respring** und bestätige den Respring.

Die Homebar bleibt ohne deine Aktivierung aus. Die Gesten funktionieren unabhängig
davon. Für das Einstellungsmenü wird PreferenceLoader als Abhängigkeit mitinstalliert.

Bei eingeschalteter Homebar versucht der Tweak, die native Leiste auf dem Homescreen
und in Apps sichtbar zu halten. Über die Systemeinstellungen der App-Szenen wird
unten mindestens 21 Punkte Platz reserviert; größere Systemabstände bleiben erhalten.
Es wird kein Little16R-Code in Apps injiziert. Behält eine App danach noch ihr altes
Layout, schließe sie im App-Wechsler und öffne sie erneut.

Das ist experimentell: Spiele, ältere Apps und eigene Layouts können den Abstand
ignorieren. Bei Sperren und Systemübergängen kann die Leiste weiterhin verschwinden.
Prüfe insbesondere Tastatur, Querformat, Tab-Leisten und Vollbild-Apps. Bei Problemen
den Schalter wieder ausschalten und übernehmen. Falls der Respring-Button auf deinem
Jailbreak nicht reagiert, den dort vorhandenen Respring verwenden.

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
