import 'package:cookie_jar/cookie_jar.dart';
import 'dart:io';

import 'package:neo2/main.dart';

const userAgent =
    "Mozilla/5.0 (X11; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0";

Future<HttpClientResponse> get(Uri url,
    {Map<String, String>? headers, CookieJar? cookieJar}) async {
  HttpClient client = HttpClient();
  client.userAgent = userAgent;
  HttpClientRequest clientRequest = await client.getUrl(url);

  cookieJar != null
      ? clientRequest.cookies.addAll(await cookieJar.loadForRequest(url))
      : {};

  headers != null
      ? headers.forEach((key, value) {
          clientRequest.headers.set(key, value);
        })
      : {};

  HttpClientResponse res = await clientRequest.close();

  logger.i(res.headers);

  return res;
}
