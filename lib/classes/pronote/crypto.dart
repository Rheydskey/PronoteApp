import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
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
  static Digest getDigest(String? tohash) {
    List<int> bytes = tohash != null ? utf8.encode(tohash) : [];

    return md5.convert(bytes);
  }

  static List<int> getBytes(String? tohash) => getDigest(tohash).bytes;
  static List<int> getDigestUtf8(String? tohash) =>
      utf8.encode(getDigestString(tohash));

  static String getDigestString(String? tohash) => getDigest(tohash).toString();
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

  AesIv(this.iv);

  static AesIv fromRandomBytes() => AesIv.from(() => Random().nextInt(1 << 32));

  static AesIv zeros() => AesIv.from(() => 0);

  static AesIv from(int Function() bytesfn) {
    List<int> bytes = [];

    for (var i = 0; i < 16; i++) {
      bytes.add(bytesfn());
    }

    return AesIv(bytes);
  }
}

class Aes {
  late List<int> key;
  Aes({String? key}) {
    setKey(key);
  }

  void setKey(String? key) => this.key = Md5.getBytes(key);

  Future<List<int>> aesCipher(String data,
      {AesIv? aesiv, bool disableCompression = true}) async {
    AesCbc aes = AesCbc.with128bits(macAlgorithm: MacAlgorithm.empty);

    List<int> iv = aesiv != null ? aesiv.iv : AesIv.zeros().iv;

    List<int> utf8encoded = disableCompression
        ? utf8.encode(data)
        : Compression.deflate(utf8.encode(data));

    SecretKey secretKey = SecretKey(key);

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
  AesIv aesIv = AesIv.zeros();

  Cipher(this.rsaKey, {this.aes});

  Future<List<int>?> cipher(String data) async {
    return await aes?.aesCipher(data);
  }

  /// Return base64
  String rsaEncryptString(String data) => rsaKey.getKey().encrypt(data);

  Uint8List rsaEncrypt(Uint8List data) => rsaKey.getKey().encryptData(data);
}
