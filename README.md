# 🌙 MoonFlow – Zyklus- & Community-App

**MoonFlow** ist eine plattformübergreifende Flutter-App zur Menstruationszyklusverfolgung mit integriertem Community-Forum und Partner-Modus.  
Die App bietet Frauen eine diskrete, sichere und benutzerfreundliche Möglichkeit, ihren Zyklus zu dokumentieren, Symptome zu tracken und sich mit anderen auszutauschen.

---

## ✨ Features

- **Zykluskalender** – Übersichtliche Darstellung des Menstruationszyklus  
- **Symptom-Tracker** – Dokumentation von Symptomen, Stimmungen und Notizen  
- **Community-Forum** – Austausch von Erfahrungen und Tipps mit anderen Nutzerinnen  
- **Partner-Modus** – Teilen des Zyklus mit einer vertrauten Person (nur Leserechte)  
- **Sichere Authentifizierung** – Firebase Auth für Login/Registrierung  
- **Cloud-Speicherung** – Cloud Firestore für Daten- und Nachrichtenverwaltung  
- **Datenschutzfokus** – Diskretes Design, verschlüsselte Kommunikation, minimale Datenspeicherung  

---

## 🛠 Technologien

- **Framework**: [Flutter](https://flutter.dev/) (Dart)  
- **Backend & Auth**: [Firebase Auth](https://firebase.google.com/docs/auth)  
- **Datenbank**: [Cloud Firestore](https://firebase.google.com/docs/firestore)  
- **Design**: Figma (Wireframes & UI-Design)  

---

## 📱 Screenshots

| Zykluskalender | Symptom-Tracker | Community-Forum |
| --- | --- | --- |
| ![Kalender](assets/screenshots/IMG-6(calender).jpg) | ![Tracker](assets\screenshots\IMG-7(homepage).jpg) | ![Forum](assets\screenshots\IMG-13(forum).jpg) |

---

## 📋 User Stories

1. **Zyklusverfolgung**  
   *Als Nutzerin möchte ich meinen Menstruationszyklus und Symptome protokollieren, um meine Gesundheit besser zu verstehen.*  
   - Kalenderübersicht  
   - Eingabe von Daten & Symptomen  
   - Erinnerungsfunktionen  

2. **Community-Austausch**  
   *Als Nutzerin möchte ich Erfahrungen mit anderen teilen und mich austauschen, um Unterstützung zu finden.*  
   - Posten von Beiträgen  
   - Kommentarfunktion  

3. **Partner-Modus**  
   *Als Nutzerin möchte ich meinen Zyklus mit einer vertrauten Person teilen können, ohne die Kontrolle über meine Daten zu verlieren.*  
   - Leserechte für Partner:innen  
   - Benachrichtigungen bei Updates  

---

## 🚀 Installation & Setup

1. **Repository klonen**  

   ```bash
   git clone https://github.com/DEIN_USERNAME/moonflow.git
   cd moonflow
   ```

2. **Abhängigkeiten installieren**  

   ```bash
   flutter pub get
   ```

3. **Firebase konfigurieren**  
   - Gehe zu [Firebase Console](https://console.firebase.google.com/)  
   - Neues Projekt anlegen  
   - Android- & iOS-App registrieren  
   - `google-services.json` (Android) bzw. `GoogleService-Info.plist` (iOS) hinzufügen  
   - Authentifizierung & Firestore aktivieren  

4. **App starten**  

   ```bash
   flutter run
   ```

---

## 🤝 Beitragende

- **Auriol Sopning**
- **Suzie Djouko**  
- **Davina Daouda**

---

## 📄 Lizenz

Dieses Projekt steht unter der **MIT-Lizenz**.  
Details siehe [LICENSE](LICENSE).

---

## 💡 Beitragen

Pull Requests sind willkommen!  
Falls du größere Änderungen planst, eröffne bitte vorher ein Issue zur Diskussion.
