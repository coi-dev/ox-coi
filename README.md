# Project on hold for now
**Please note that the OX COI Messenger project is currently not active.** 
In the past this project was hindered by the lack of Rust expertise on side of the project maintainers. Work is underway to create a new approach which also allows users to manage normal email messages. If and when we have something to announce, we will update this section. For now, we keep this reference for interested developers. 

# OX COI Messenger

OX COI Messenger is a mail based chat app. This app provides the user interface for an IMAP / SMTP based chat on Android and iOS.

- **Android state:** Available as beta at the [Google Play Store](https://play.google.com/store/apps/details?id=com.openxchange.oxcoi)
- **iOS state:** Available as beta at [Apple TestFlight](https://testflight.apple.com/join/VoqodiHt)
- **More info**: More info at [www.coi.me](http://www.coi.me)

## Information
- The [Developer Documentation](https://github.com/open-xchange/ox-coi/wiki/Developer-Documentation) and the [wiki](https://github.com/open-xchange/ox-coi/wiki) in general provide information around the app, the code and the general idea of COI
- The IMAP / SMTP interactions are managed by the [Flutter Delta Chat Core Plugin](https://github.com/open-xchange/flutter-deltachat-core)
  - The Flutter plugin uses the [Delta Chat Core](https://github.com/deltachat/deltachat-core-rust) library to realize the actual message handling

## Requirements
- Flutter **1.17.2** is used
- [Android setup](https://github.com/open-xchange/ox-coi/wiki/Development-Setup-for-Android)
- [iOS setup](https://github.com/open-xchange/ox-coi/wiki/Development-Setup-for-iOS)
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
