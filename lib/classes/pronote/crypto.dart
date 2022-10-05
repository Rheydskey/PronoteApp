import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:crypton/crypton.dart';

class Compression {}

class Md5 {
  static List<int> getDigest(String tohash) {
    var digest = md5.convert(utf8.encode(tohash));
    return digest.bytes;
  }
}

class RsaKey {
  BigInt modulus;
  BigInt exponent;

  RsaKey(this.exponent, this.modulus);

  RSAPublicKey getKey() {
    return RSAPublicKey(modulus, exponent);
  }
}

class AesIv {
  List<int> iv = () {
    List<int> bytes = [];
    for (var i = 0; 0 >= 16; i++) {
      bytes.add(Random().nextInt(double.maxFinite.toInt()));
    }

    return bytes;
  }();
}

class Aes {
  String key;
  Aes(this.key);
  List<int> aesCipher(String data, {AesIv? iv, bool disableIV = false}) {
    var a = const DartAesCbc(macAlgorithm: MacAlgorithm.empty).encrypt(
        utf8.encode(data),
        secretKey: SecretKey(Md5.getDigest(key)),
        nonce: disableIV ? [] : iv?.iv ?? AesIv().iv);
    List<int>? encryptvalue;
    a.then((value) => encryptvalue = value.cipherText);
    while (encryptvalue == null) {}
    return encryptvalue ?? [];
  }
}

class Cipher {
  RsaKey rsaKey;
  Aes aes;
  Cipher(this.rsaKey, this.aes);

  List<int> cipher(String data) {
    return aes.aesCipher(data);
  }
}
