import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:neo2/classes/http/http.dart';
import 'package:neo2/classes/pronote/crypto.dart';
import 'package:neo2/classes/pronote/pronote.dart';
import 'package:neo2/main.dart';

void request(Pronote session, String name,
    {Map<String, dynamic>? content = const {}}) async {
  Cipher cipher = session.getCipher();

  Aes aes = cipher.aes != null ? cipher.aes! : Aes();

  session.requestCount += 2;

  String order = await aes.aesToHexa(session.requestCount.toString());

  Uri url = Uri.parse(
      "${session.url.toString()}appelfonction/${session.sessionType}/${session.sessionId}/$order");
  String body = jsonEncode({
    "nom": name,
    "numeroOrdre": order,
    "session": session.sessionId,
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

  logger.i(await res.transform(utf8.decoder).join());

  session.cookieManager.saveFromResponse(url, res.cookies);
}
