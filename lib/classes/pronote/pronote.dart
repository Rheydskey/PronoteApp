import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:neo2/classes/http/http.dart';
import 'package:neo2/classes/neo.dart';
import 'package:neo2/classes/pronote/crypto.dart';
import 'package:neo2/main.dart';

class Pronote {
  Cipher? _cipher;
  CookieJar cookieManager = CookieJar();

  Pronote(this.cookieManager);

  Cipher getCipher() => _cipher!;

  void setCipher(Cipher cipher) => _cipher = cipher;

  void getUUID() {}

  static Future<Pronote> fromNeo(Neo neo) async {
    Pronote pronote = Pronote(neo.cookieManager);

    var res = await get(
        Uri.parse(
            "https://ent.l-educdenormandie.fr/cas/login?service=https://0760095R.index-education.net/pronote/"),
        headers: {"referer": "https://ent.l-educdenormandie.fr/"},
        cookieJar: neo.cookieManager);

    String body = await res.transform(utf8.decoder).join();

    Document parsed = HtmlParser(body).parse();
    String? onload =
        parsed.getElementsByTagName("body")[0].attributes['onload'];

    String? trimmed = onload
        ?.replaceAll("try { Start (", "")
        .replaceAll(") } catch (e) { messageErreur (e) }", "");

    logger.i(trimmed);

    return pronote;
  }
}
