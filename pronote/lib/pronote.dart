import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:pronote/http/http.dart';
import 'package:pronote/crypto.dart';
import 'package:pronote/crypto/rsa.dart';
import 'package:pronote/request.dart';

class Pronote {
  Uri url;
  Uri referer;
  int requestCount = -1;
  Cipher? _cipher;
  int sessionId;
  int sessionType;

  CookieJar cookieManager = CookieJar();

  Pronote(this.url, this.referer, this.cookieManager, this.sessionId,
      this.sessionType);

  Cipher getCipher() => _cipher!;

  void setCipher(Cipher cipher) => _cipher = cipher;

  Future<String> getFonctionParametres() async {
    request(this, "FonctionParametres", content: {
      "donnees": {"Uuid": getUUID(), "identifiantNav": null}
    });

    return "";
  }

  String getUUID() {
    String hexaIv = "SnjyOlbqWY86H1Wa9NvqLA==";

    String base = putrn(
        base64Encode(_cipher!.rsaEncrypt(base64Decode(hexaIv)).toList()), 64);

    return base;
  }
}

String putrn(String str, int maxlines) {
  String result = "";
  int countofsubstring = (str.length / maxlines).floor() - 1;
  var i = 0;
  for (; i <= countofsubstring; i++) {
    result += "${str.substring(i * maxlines, (i + 1) * maxlines)}\r\n";
  }

  result += str.substring(result.length - (2 * i), str.length);

  return result;
}

Future<Pronote> getPronoteSession(CookieJar cj) async {
  var res = await get(
      Uri.parse(
          "https://ent.l-educdenormandie.fr/cas/login?service=https://0760095R.index-education.net/pronote/"),
      headers: {"referer": "https://ent.l-educdenormandie.fr/"},
      cookieJar: cj);

  cj.saveFromResponse(
      Uri.parse("https://0760095R.index-education.net/pronote/"), res.cookies);

  String body = await res.transform(utf8.decoder).join();

  Document parsed = HtmlParser(body).parse();
  String? onload = parsed.getElementsByTagName("body")[0].attributes['onload'];
  if (!(onload?.startsWith("try { Start ({") ?? false)) {
    throw FormatException("bad body : $body");
  }

  String trimmed = onload
          ?.replaceAll("try { Start ({", "")
          .replaceAll("}) } catch (e) { messageErreur (e) }", "") ??
      "{}";

  /// Parsing default values
  List<String> split = trimmed
      .split(':')
      .map((e) => e.split(","))
      .expand((element) => element)
      .map((e) => e.replaceAll('\'', '').trim())
      .toList();

  Map<String, String> map = {};

  for (var i = 0; i < split.length - 1; i += 2) {
    map.addAll({split[i]: split[i + 1]});
  }

  Pronote pronote = Pronote(
      Uri.parse("https://0760095R.index-education.net/pronote/"),
      res.redirects[1].location,
      cj,
      int.parse(map['h']!),
      int.parse(map['a']!));

  Cipher cipher = Cipher(Rsa.fromNumber(
      exponent: BigInt.parse(map['ER']!),
      modulus: BigInt.parse("0x${map['MR']!}")));

  pronote.setCipher(cipher);

  pronote.getFonctionParametres();

  return pronote;
}
