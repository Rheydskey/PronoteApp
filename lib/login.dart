import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'consts.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Login {
  final _cookieManager = WebviewCookieManager();
  WebViewController? _controller;
  bool _post = false;
  bool _tokenOk = false;

  bool get isFinish => _tokenOk;

  Future<void> loginme() async {
    await _controller?.runJavascriptReturningResult("""
    document.getElementById("username").value = '$user';
    document.getElementById("password").value = '$password';
    document.getElementById("bouton_valider").click();
    """);
  }

  Future<List<Cookie>> getEducDeNomandieCookies() async {
    List<Cookie> cookie =
        await _cookieManager.getCookies("https://ent.l-educdenormandie.fr");

    while (cookie.isEmpty) {
      cookie =
          await _cookieManager.getCookies("https://ent.l-educdenormandie.fr");
    }

    return cookie;
  }

  Widget login() {
    return WebView(
      initialCookies: const [],
      navigationDelegate: (NavigationRequest request) {
        return request.url.startsWith('https://ent.l-educdenormandie.fr') &&
                _tokenOk
            ? NavigationDecision.prevent
            : NavigationDecision.navigate;
      },
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (controllerPlus) {
        _controller = controllerPlus;
        _controller?.clearCache();
      },
      onPageFinished: (url) {
        if (url.contains(
            "https://educonnect.education.gouv.fr/idp/profile/SAML2/Unsolicited/SSO")) {
          loginme();
          _post = true;
        }

        if (url.contains(
                "https://educonnect.education.gouv.fr/idp/profile/SAML2/Unsolicited/SSO") &&
            _post) {
          _tokenOk = true;
        }
      },
      initialUrl:
          "https://educonnect.education.gouv.fr/idp/profile/SAML2/Unsolicited/SSO?providerId=https%3A%2F%2Fent.l-educdenormandie.fr%2Fauth%2Fsaml%2Fmetadata%2Fidp.xml",
    );
  }
}
