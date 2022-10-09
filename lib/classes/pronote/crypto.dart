import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:crypton/crypton.dart';
import 'package:archive/archive_io.dart' as archive_io;
import 'package:neo2/main.dart';

class Compression {
  static List<int> deflate(List<int> data) {
    return archive_io.Deflate(data).getBytes();
  }

  static List<int> inflate(List<int> data) {
    return archive_io.Inflate(data).getBytes();
  }
}

class Md5 {
  static String getDigest(String? tohash) {
    List<int> bytes = tohash != null ? utf8.encode(tohash) : [];

    return md5.convert(bytes).toString();
  }
}

class RsaKey {
  BigInt modulus;
  BigInt exponent;

  RsaKey({required this.exponent, required this.modulus});

  RSAPublicKey getKey() {
    return RSAPublicKey(modulus, exponent);
  }
}

class AesIv {
  List<int> iv = [];

  AesIv() {
    List<int> bytes = [];

    for (var i = 0; i < 16; i++) {
      bytes.add(Random().nextInt(1 << 32));
    }

    iv = bytes;
  }
}

class Aes {
  late String key;
  Aes({String? key}) {
    setKey(key);
  }

  void setKey(String? key) => this.key = Md5.getDigest(key);

  Future<List<int>> aesCipher(String data,
      {AesIv? aesiv, bool disableCompression = true}) async {
    DartAesCbc aes =
        const DartAesCbc(macAlgorithm: MacAlgorithm.empty, secretKeyLength: 16);

    List<int> iv = aesiv != null ? aesiv.iv : [];

    List<int> utf8encoded = disableCompression
        ? utf8.encode(data)
        : Compression.deflate(utf8.encode(data));

    SecretKey secretKey = SecretKey(utf8.encode(key));

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
  String rsaEncryptString(String data) => rsaKey.getKey().encrypt(data);

  Uint8List rsaEncrypt(Uint8List data) => rsaKey.getKey().encryptData(data);
}
