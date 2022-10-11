import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class Rsa {
  RSAPublicKey pronoteKey;

  Rsa(this.pronoteKey);

  String encrypt(String data) {
    return base64Encode(encryptData(data as Uint8List));
  }

  Uint8List encryptData(Uint8List data) {
    ///RSA Encryption Scheme from PKCS #1 version 1.5 (RSAES-PKCS1-v1_5), is implemented by the PKCS1Encoding class.
    final p = AsymmetricBlockCipher('RSA/PKCS1');
    p.init(true, PublicKeyParameter<RSAPublicKey>(pronoteKey));
    return p.process(data);
  }

  static Rsa fromNumber({required BigInt modulus, required BigInt exponent}) {
    return Rsa(RSAPublicKey(modulus, exponent));
  }
}
