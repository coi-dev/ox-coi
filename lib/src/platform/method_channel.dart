import 'package:flutter/services.dart';

class SecurityChannel {
  static const _name = 'oxcoi.security';

  static const kMethodDecrypt = 'decrypt';

  static const kArgumentContent = 'encryptedBase64Content';
  static const kArgumentPrivateKey = 'privateKeyBase64';
  static const kArgumentPublicKey = 'publicKeyBase64';
  static const kArgumentAuth = 'authBase64';

  static const instance = const MethodChannel(_name);
}

class SharingChannel {
  static const _name = 'oxcoi.sharing';

  static const kMethodGetSharedData = 'getSharedData';
  static const kMethodSendSharedData = 'sendSharedData';
  static const kMethodGetInitialLink = 'getInitialLink';

  static const kArgumentMimeType = 'mimeType';
  static const kArgumentText = 'text';
  static const kArgumentPath = 'path';
  static const kArgumentFileName = 'fileName';
  static const kArgumentTitle = 'title';

  static const instance = const MethodChannel(_name);
}
