import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String generateSalt([int length = 16]) {
  final rand = Random.secure();
  final saltBytes = List<int>.generate(length, (_) => rand.nextInt(256));
  return base64.encode(saltBytes);
}

// Hash input + salt using SHA-256 and return base64 encoded string
String hashWithSalt(String input, String salt) {
  final bytes = utf8.encode(input + salt);
  final digest = sha256.convert(bytes);
  return base64.encode(digest.bytes);
}