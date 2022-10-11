import 'dart:typed_data';

import 'package:pronote/crypto/aes.dart';
import 'package:pronote/crypto/rsa.dart';

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
