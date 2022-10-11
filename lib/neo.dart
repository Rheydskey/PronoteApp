import 'dart:convert';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:pronote/http/http.dart';

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
  CookieJar cookieManager = CookieJar();

  Neo({required List<Cookie> educ}) {
    cookieManager.saveFromResponse(
        Uri.parse("https://ent.l-educdenormandie.fr/userbook/api/person"),
        educ);
  }

  Future<Person> getPerson() async {
    var e = await get(
        Uri.parse("https://ent.l-educdenormandie.fr/userbook/api/person"),
        cookieJar: cookieManager);
    var json = jsonDecode(await e.transform(utf8.decoder).join());
    return Person.fromJson(json['result'][0]);
  }
}
