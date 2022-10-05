import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart';
import 'package:neo2/classes/neo.dart';
import 'package:neo2/classes/pronote/crypto.dart';
import 'package:neo2/main.dart';

class Pronote {
  Cipher? _cipher;
  CookieManager cookieManager = CookieManager(CookieJar());
  Dio dio = Dio();

  Pronote(CookieManager cookieManager) {
    dio.interceptors.add(cookieManager);
  }

  Cipher getCipher() => _cipher!;

  void setCipher(Cipher cipher) => this._cipher = cipher;

  void getUUID() {}

  static Future<Pronote> fromNeo(Neo neo) async {
    Pronote pronote = Pronote(neo.cookieManager);

    var res = await pronote.dio.get(
        "https://ent.l-educdenormandie.fr/cas/login?service=https://0760095R.index-education.net/pronote/",
        options:
            Options(headers: {"referer": "https://ent.l-educdenormandie.fr/"}));

    var body = res.data;

    var stringBody = body as String;

    logger.i(stringBody.split("").length);

    if (body is! String) {
      throw FormatException("Body is not a string");
    }
    print(body);
    var parsed = HtmlParser(body as String).parse();
    print(parsed.getElementsByTagName("body")[0]);

    return pronote;
  }
}
