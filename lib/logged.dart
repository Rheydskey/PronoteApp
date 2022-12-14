import 'package:flutter/material.dart';
import 'package:neo2/neo.dart';
import 'package:pronote/pronote.dart';

class Logged extends StatefulWidget {
  final Neo neo;

  const Logged(this.neo, {super.key});

  @override
  State<StatefulWidget> createState() => _LoggedState();
}

class _LoggedState extends State<Logged> {
  Person? person;
  @override
  void initState() {
    widget.neo.getPerson().then((value) => {
          setState(() => {person = value})
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person?.displayName ?? "Loading..."),
        actions: [
          IconButton(
              onPressed: () => {getPronoteSession(widget.neo.cookieManager)},
              icon: const Icon(Icons.refresh))
        ],
      ),
      body:
          centerCard(context, Text(person?.schools.classes[0] ?? "Loading...")),
    );
  }
}

Widget centerCard(BuildContext context, Widget widget) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 200,
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [widget],
    ),
  );
}
