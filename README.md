# OX Talk

OX Talk is a mail based chat app. This app provides the user interface for an IMAP / SMTP based chat on Android and iOS.

## Relevant information
- [Documentation](https://confluence-public.open-xchange.com/display/COIPublic/OX+Talk+Mobile+App)
- The IMAP / SMTP interactions are managed by the [delta_chat_core](https://gitlab.open-xchange.com/mobile/talk/tree/develop/delta_chat_core) plugin

## Requirements
- As Flutter is still under development the newest version of Flutter and the Flutter plugin is required (at least until 1.0 is reached)

## Execution of the Flutter app
As for now (08.11.2018) it is required to execute the example app inside the project from console using ```flutter run --target-platform android-arm``` as the DCC is written as 32 bit program and Flutter is a 
64 bit program (see https://github.com/flutter/flutter/issues/15530). When using an IDE use ```--target-platform android-arm``` as additional argument in your run configuration.

## Development
To be able to edit / extend the ox_talk app the following steps are important after checking out / altering the project:
- No special requirements

### Flutter 

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

### Dart

Flutter is based on Dart, more information regarding Dart can be found on the [official website](https://www.dartlang.org/).
