# OX COI Messenger

OX COI Messenger is a mail based chat app. This app provides the user interface for an IMAP / SMTP based chat on Android and iOS.

- **Android state:** Available as beta at the [Google Play Store](https://play.google.com/store/apps/details?id=com.openxchange.oxcoi), more info at [www.coi.me](http://www.coi.me)
- **iOS state:** Currently in development (2019-11: first internal test release, public release coming soon)

## Testing OX COI Messenger
OX COI Messenger is available as beta - not to be used in production - for both Android and iOS:
* [Google Play](https://play.google.com/store/apps/details?id=com.openxchange.oxcoi)
* [Apple TestFlight](https://testflight.apple.com/join/VoqodiHt)

## Information
- The [Developer Documentation](https://github.com/open-xchange/ox-coi/wiki/Developer-Documentation) and the [wiki](https://github.com/open-xchange/ox-coi/wiki) in general provide information around the app, the code and the general idea of COI
- The IMAP / SMTP interactions are managed by the [Flutter Delta Chat Core Plugin](https://github.com/open-xchange/flutter-deltachat-core)
  - The Flutter plugin uses the [Delta Chat Core](https://github.com/deltachat/deltachat-core-rust) library to realize the actual message handling

## Requirements
- Flutter **v1.9.1+hotfix.6** is used
- The [Flutter Delta Chat Core Plugin](https://github.com/open-xchange/flutter-deltachat-core) needs to be checked out right beside the OX COI Messenger app (the repositories should be located in the same folder)
  - Please follow the requirements given by the plugin project before building the app project

## Execution
- Fullfil all [requirements](https://github.com/open-xchange/ox-coi#requirements)
- Connect a smartphone to your PC or start an emulator / a simulator
- Enable Dart and Flutter support within your IDE
- Build and run the project via your IDE / Flutter CLI

## Development
To be able to edit / extend this project the following steps are important:

- Create an issue with relevant information regarding your fix / extension for the project
- Setup the project (please see the [requirements](https://github.com/open-xchange/ox-coi#requirements) and [execution](https://github.com/open-xchange/ox-coi#execution) sections)
- Implement your changes (please see the [coding guidelines](https://github.com/open-xchange/ox-coi/wiki/Coding-Guidelines)) on a feature branch (please see the [how to contribute](https://github.com/open-xchange/ox-coi/wiki/How-to-contribute) guide)
- Add [tests](https://github.com/open-xchange/ox-coi/wiki/Testing)
- Create a pull request (please see the [how to contribute](https://github.com/open-xchange/ox-coi/wiki/How-to-contribute) guide)

### Flutter 

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

### Dart

Flutter is based on Dart, more information regarding Dart can be found on the [official website](https://www.dartlang.org/).
