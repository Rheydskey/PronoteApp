import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:crypton/crypton.dart';
import 'package:archive/archive_io.dart' as archive_io;

class Compression {
  static List<int> deflate(List<int> data) {
    return archive_io.Deflate(data).getBytes();
  }

  static List<int> inflate(List<int> data) {
    return archive_io.Inflate(data).getBytes();
  }
}

class Md5 {
  static String getDigest(String tohash) {
    return md5.convert(utf8.encode(tohash)).toString();
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
  List<int> iv = [];

  AesIv() {
    List<int> bytes = [];
    for (var i = 0; 0 >= 16; i++) {
      bytes.add(Random().nextInt(double.maxFinite.toInt()));
    }
    iv = bytes;
  }
}

class Aes {
  String key;
  Aes(this.key);
  Future<List<int>> aesCipher(String data,
      {AesIv? aesiv, bool disableCompression = true}) async {
    DartAesCbc aes = const DartAesCbc(macAlgorithm: MacAlgorithm.empty);

    List<int> iv = aesiv != null ? aesiv.iv : [];
    List<int> utf8encoded = disableCompression
        ? utf8.encode(data)
        : Compression.deflate(utf8.encode(data));
    String listBytesKey = Md5.getDigest(key);
    SecretKey secretKey = SecretKey(utf8.encode(listBytesKey));

    SecretBox secretbox =
        await aes.encrypt(utf8encoded, secretKey: secretKey, nonce: iv);

    return secretbox.cipherText;
  }

  Future<String> aesToHexa(String data) async {
    List<int> dataCipher = await aesCipher(data);
    return dataCipher.map((el) => el.toRadixString(16).padLeft(2, '0')).join();
  }
}

class Cipher {
  RsaKey rsaKey;
  Aes? aes;
  AesIv aesIv = AesIv();

  Cipher(this.rsaKey, {this.aes});

  Future<List<int>?> cipher(String data) async {
    return await aes?.aesCipher(data);
  }

  /// Return base64
  String rsaString(String data) {
    return rsaKey.getKey().encrypt(data);
  }

  Uint8List rsaData(Uint8List data) {
    return rsaKey.getKey().encryptData(data);
  }
}
