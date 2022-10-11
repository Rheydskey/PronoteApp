import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:pronote/crypto/compression.dart';
import 'package:pronote/crypto/md5.dart';

class AesIv {
  Uint8List iv;

  AesIv(this.iv);

  static AesIv fromRandomBytes() =>
      AesIv.from((random) => random.nextInt(1 << 32));

  static AesIv zeros() => AesIv.from((_) => 0);

  static AesIv from(int Function(Random) bytesfn) {
    final Random generator = Random.secure();
    Uint8List bytes = Uint8List(16);

    for (var i = 0; i < 16; i++) {
      bytes[i] = bytesfn(generator);
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
