import 'dart:typed_data';

import 'package:crypton/crypton.dart';
import 'package:pronote/crypto/aes.dart';
import 'package:pronote/crypto/rsa.dart';

class RsaKey {
  BigInt modulus;
  BigInt exponent;

  RsaKey({required this.exponent, required this.modulus});

  RSAPublicKey getKey() {
    return RSAPublicKey(modulus, exponent);
  }

  static RsaKey fromString(String exponent, String modulus) => RsaKey(
      exponent: BigInt.parse(exponent), modulus: BigInt.parse("0x$modulus"));
}

class Cipher {
  Rsa rsa;
  Aes? aes;
  AesIv aesIv = AesIv.zeros();

  Cipher(this.rsa, {this.aes});

  Future<List<int>?> cipher(String data) async {
    return await aes?.aesCipher(data);
  }

  /// Return base64
  String rsaEncryptString(String data) => rsa.encrypt(data);

  Uint8List rsaEncrypt(Uint8List data) => rsa.encryptData(data);
}
