import 'package:auto_size_text/auto_size_text.dart';
import 'package:ekonomika/colors.dart';
import 'package:ekonomika/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'core/formula_parser.dart';


late Tuple2<List<Tuple2<String, List<Formula>>>, List<Variable>> mainData;

void main() async {
  runApp(const MyApp());
  mainData = await FormulaParser().parse();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ekonomika',
      theme: ThemeData(
        canvasColor: HexColor.fromHex(MyColors.backgroundColor),
      ),
      home: const MyHomePage(title: 'ekonomika'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: HexColor.fromHex(MyColors.secondaryBackgroundColor),
        title: Align(
          alignment: Alignment.center,
          child: AutoSizeText(
            widget.title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        toolbarHeight: 45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24.0),
          ),
        ),
      ),
      body: MainMenu(),
    );
  }
}
