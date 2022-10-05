import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class Person {
  String id;
  String login;
  String displayName;
  String type;
  Schools schools;
  Person(this.id, this.login, this.displayName, this.type, this.schools);

  static Person fromJson(Map<String, dynamic> json) {
    return Person(
        json["id"],
        json["login"],
        json["displayName"],
        json["type"].toString(),
        Schools.fromJson((json["schools"] as List<dynamic>)[0]));
  }

  @override
  String toString() {
    return "Person {id: $id}";
  }
}

class Schools {
  String id;
  List<String> classes;
  String name;

  Schools(this.id, this.classes, this.name);

  static Schools fromJson(Map<String, dynamic> json) {
    return Schools(
        json['id'],
        (json['classes'] as List<dynamic>).map((e) => e.toString()).toList(),
        json['name']);
  }
}

class Neo {
  CookieManager cookieManager = CookieManager(CookieJar());
  Dio dio = Dio();

  Neo({required List<Cookie> educ}) {
    dio.interceptors.add(cookieManager);

    cookieManager.cookieJar.saveFromResponse(
        Uri.parse("https://ent.l-educdenormandie.fr/userbook/api/person"),
        educ);
  }

  void printCookies() async {
    print(await cookieManager.cookieJar
        .loadForRequest(Uri.parse("https://ent.l-educdenormandie.fr")));
  }

  Future<Person> getPerson() async {
    var e =
        await dio.get("https://ent.l-educdenormandie.fr/userbook/api/person");

    return Person.fromJson(e.data['result'][0]);
  }
}
