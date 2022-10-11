import 'dart:convert';
import 'dart:io';

import 'package:pronote/http/http.dart';
import 'package:pronote/crypto.dart';
import 'package:pronote/crypto/aes.dart';
import 'package:pronote/pronote.dart';

void request(Pronote session, String name,
    {Map<String, dynamic>? content = const {}}) async {
  Cipher cipher = session.getCipher();

  Aes aes = cipher.aes != null ? cipher.aes! : Aes();

  session.requestCount += 2;

  String order = await aes.aesToHexa(session.requestCount.toString());

  Uri url = Uri.parse(
      "${session.url.toString()}appelfonction/${session.sessionType}/${session.sessionId}/$order");
  String body = jsonEncode({
    "session": session.sessionId,
    "numeroOrdre": order,
    "nom": name,
    "donneesSec": content
  });

  HttpClientResponse res = await post(url,
      content: body,
      headers: {
        "Content-Type": "application/json",
        "Connection": "keep-alive",
        "Referer": session.referer.toString()
      },
      cookieJar: session.cookieManager);

  print(await res.transform(utf8.decoder).join());

  session.cookieManager.saveFromResponse(url, res.cookies);
}
