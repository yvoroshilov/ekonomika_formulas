
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ekonomika/colors.dart';
import 'package:ekonomika/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:tuple/tuple.dart';

import 'core/formula_parser.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {

  final TeXViewRenderingEngine renderingEngine = const TeXViewRenderingEngine.katex();
  final FormulaParser formulaParser = FormulaParser();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    List<Tuple2<String, List<Formula>>> topics = mainData.item1;
    topics.sort((a, b) => a.item1.compareTo(b.item1));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: HexColor.fromHex(MyColors.secondaryBackgroundColor),
        title: const AutoSizeText(
          'Topics',
          maxLines: 1,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        toolbarHeight: 45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24.0),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              String topic = topics[index].item1;
              List<Formula> formulas = topics[index].item2;
              Map<String, Variable> varrs = {};

              List<TeXViewDocument> texDocs = [];
              for (Formula formul in formulas) {
                texDocs.add(TeXViewDocument(formul.latex));
                varrs.addAll(formul.variables);
              }

              List<TeXViewDocument> varTexDocs = [];
              for (Variable varr in varrs.values) {
                varTexDocs.add(TeXViewDocument(
                  r'\( ' + varr.latex + r' \) - ' + varr.description,
                ));
              }
              return ExpansionTile(
                title: Container(
                  width: double.infinity,
                  child: Text(
                    topic,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                children: [
                  TeXView(
                    loadingWidgetBuilder: (ctxt) => CircularProgressIndicator(),
                    renderingEngine: renderingEngine,
                    child: TeXViewColumn(
                      children: texDocs + varTexDocs,
                    ),
                  ),
                ],
                trailing: Icon(Icons.arrow_drop_down_circle_outlined),
              );
            }
        ),
      ),
    );
  }
}