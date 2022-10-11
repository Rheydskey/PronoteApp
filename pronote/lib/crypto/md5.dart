import 'package:crypto/crypto.dart';
import 'dart:convert';

class Md5 {
  static Digest getDigest(String? tohash) {
    List<int> bytes = tohash != null ? utf8.encode(tohash) : [];

    return md5.convert(bytes);
  }

  static List<int> getBytes(String? tohash) => getDigest(tohash).bytes;
  static List<int> getDigestUtf8(String? tohash) =>
      utf8.encode(getDigestString(tohash));

  static String getDigestString(String? tohash) => getDigest(tohash).toString();
}
