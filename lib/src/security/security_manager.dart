import 'dart:convert';

import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/security/security_generator.dart';
import 'package:pointycastle/pointycastle.dart';
// ignore: implementation_imports
import 'package:pointycastle/src/utils.dart'; // Required implementation import to allow encoding / decoding of BigInt <-> ByteArray

Future<void> generateAndPersistPushKeyPairAsync() async {
  final keyPair = generateEcKeyPair();
  final publicKey = _extractBase64PublicEcKey(keyPair);
  final privateKey = _extractBase64PrivateEcKey(keyPair);
  await setPreference(preferenceNotificationKeyPublic, publicKey);
  await setPreference(preferenceNotificationKeyPrivate, privateKey);
}

String _extractBase64PublicEcKey(AsymmetricKeyPair keyPair) {
  final ECPublicKey publicKey = keyPair.publicKey;
  final encodedKey = publicKey.Q.getEncoded(false);
  return base64UrlEncode(encodedKey);
}

String _extractBase64PrivateEcKey(AsymmetricKeyPair keyPair) {
  final ECPrivateKey privateKey = keyPair.privateKey;
  final encodedKey = encodeBigInt(privateKey.d);
  return base64UrlEncode(encodedKey);
}

Future<void> generateAndPersistPushAuthAsync() async {
  final auth = generateRandomBytes();
  final encodedAuth = base64UrlEncode(auth);
  await setPreference(preferenceNotificationsAuth, encodedAuth);
}

Future<String> getPushPrivateKeyAsync() async {
  return await getPreference(preferenceNotificationKeyPrivate);
}

Future<String> getPushPublicKeyAsync() async {
  return await getPreference(preferenceNotificationKeyPublic);
}

Future<String> getPushAuthAsync() async {
  return await getPreference(preferenceNotificationsAuth);
}