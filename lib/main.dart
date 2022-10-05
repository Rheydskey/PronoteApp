import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:neo2/classes/neo.dart';
import 'package:neo2/logged.dart';
import 'package:neo2/login.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

Logger logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Login login = Login();
  List<Cookie>? _cookies;
  bool _finish = false;

  @override
  void initState() {
    final cookieManager = WebviewCookieManager();
    cookieManager.clearCookies();
    setIfFinished();
    super.initState();
  }

  void setIfFinished() {
    login.getEducDeNomandieCookies().then((value) => setState(() {
          _cookies = value;
          changeView();
        }));
  }

  void changeView() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Logged(Neo(educ: _cookies!))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neo²"),
      ),
      body: Stack(children: [
        login.login(),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ]),
    );
  }
}
