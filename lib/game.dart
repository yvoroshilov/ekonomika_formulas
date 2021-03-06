import 'package:auto_size_text/auto_size_text.dart';
import 'package:ekonomika/core/random_formula.dart';
import 'package:ekonomika/main.dart';
import 'package:ekonomika/util_ui.dart';
import 'package:ekonomika/win_screen.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:tuple/tuple.dart';

import 'colors.dart';
import 'core/formula_parser.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    Key? key,
    required this.max,
  }) : super(key: key);

  final int max;

  @override
  State<StatefulWidget> createState() => _GamePage();
}

class _GamePage extends State<GamePage> {

  final TeXViewRenderingEngine renderingEngine = const TeXViewRenderingEngine.katex();
  final FormulaParser formulaParser = FormulaParser();
  final RandomFormula randForm = RandomFormula();

  Tuple2<List<Tuple2<String, List<Formula>>>, List<Variable>>? parseResult;
  late Formula randomFormula;
  late Formula hiddenFormula;
  late List<TeXViewDocument> hints;
  late List<Variable> vars;
  late Variable hiddenVar;
  List<TeXViewWidget> variants = [];
  List<Formula> excludedFormulas = [];

  List<Widget> progressComponents = [];
  int curStep = 1;
  int guessedNumber = 0;
  bool lastGuessWin = false;
  Widget? resultText;


  void generate(Tuple2<List<Tuple2<String, List<Formula>>>, List<Variable>> data) {
    parseResult = data;
    List<Tuple2<String, List<Formula>>> topics = data.item1;
    List<Variable> allVars = data.item2;
    List<Formula> allFormulas = [];

    for (Tuple2<String, List<Formula>> top in topics) {
      allFormulas.addAll(top.item2);
    }

    randomFormula = randForm.getRandomFormula(allFormulas, excludedFormulas);

    Tuple2<String, Formula> hiddenResult = randForm.hideVar(randomFormula);
    hiddenVar = randomFormula.variables[hiddenResult.item1]!;
    hiddenFormula = hiddenResult.item2;

    vars = randForm.getRandomVariables(4, allVars, [hiddenVar]);
    vars.add(hiddenVar);
    vars.shuffle();

    hints = [];
    for (MapEntry<String, Variable> entry in hiddenFormula.variables.entries) {
      String id = entry.key;
      Variable varr = entry.value;
      if (varr != Variable.hiddenVariable) {
        hints.add(TeXViewDocument(
          r'\( ' + varr.latex + r' \) - ' + varr.description,
        ));
      }
    }
  }

  void addProgressComponent(BuildContext context, double fullMargin, bool win) {
    double componentWidth = (MediaQuery.of(context).size.width - fullMargin) / widget.max;
    progressComponents.add(
      Stack(
        children: [
          Container(
            width: componentWidth,
            color: win ? Colors.green : Colors.red,
            child: Align(
              alignment: Alignment.center,
              child: Text(curStep.toString()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    resultText = null;
    lastGuessWin = false;
    generate(mainData);
    getVariants(5);
  }

  void doNextStep() {
    setState(() {
      resultText = null;
      lastGuessWin = false;
      excludedFormulas.add(randomFormula);
      generate(mainData);
      getVariants(5);
      curStep++;
    });
  }

  void getVariants(int count) {
    variants = [];
    for (int index = 0; index < count; index++) {
      variants.add(TeXViewInkWell(
        id: vars[index].id,
        child: TeXViewDocument(r'$$ ' + vars[index].latex + r' $$'),
        style: const TeXViewStyle(
          height: 50,
          margin: TeXViewMargin.only(top: 4, bottom: 4),
          textAlign: TeXViewTextAlign.Center,
          // backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
          backgroundColor: Colors.white,
          borderRadius: TeXViewBorderRadius.all(20),
          border: TeXViewBorder.all(TeXViewBorderDecoration(
            borderWidth: 1,
            borderColor: Colors.black,
            borderStyle: TeXViewBorderStyle.Solid,
          )),
        ),
        onTap: (id) {
          if (resultText != null) return;
          if (id == hiddenVar.id) {
            setState(() {
              lastGuessWin = true;
              resultText = Column(
                children: [
                  const Text(
                    r'??????????????????!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                    ),
                  ),
                  TeXView(
                    style: TeXViewStyle(
                      backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
                      textAlign: TeXViewTextAlign.Center,
                    ),
                    child: TeXViewColumn(
                      children: [
                        TeXViewDocument(
                          r'\(' + randomFormula.latex.replaceAll(r'$', '') + r'\)',
                          style: TeXViewStyle(
                            backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
                            textAlign: TeXViewTextAlign.Center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
          } else {
            setState(() {
              lastGuessWin = false;
              resultText = Column(
                children: [
                  const Text(
                    r'????????????! ???????????????????? ??????????: ',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                  TeXView(
                    style: TeXViewStyle(
                      backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
                      textAlign: TeXViewTextAlign.Center,
                    ),
                    child: TeXViewColumn(
                      children: [
                        TeXViewDocument(
                          r'\(' + randomFormula.latex.replaceAll(r'$', '') + r'\)',
                          style: TeXViewStyle(
                            backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
                            textAlign: TeXViewTextAlign.Center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
          }
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: HexColor.fromHex(MyColors.secondaryBackgroundColor),
        title: AutoSizeText(
          '?????????? $curStep',
          maxLines: 1,
          style: const TextStyle(
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
      body: Column(
        children: [
          Container(
            height: 35,
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.black),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Row(
                  children: progressComponents,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              key: ValueKey<int>(curStep),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 150,
                    maxHeight: 200,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [TeXView(
                        renderingEngine: renderingEngine,
                        loadingWidgetBuilder: (ctxt) => const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                        style: TeXViewStyle(
                          height: 80,
                          fontStyle: TeXViewFontStyle(
                            fontSize: 18,
                          ),
                        ),
                        child: TeXViewDocument(
                          hiddenFormula.latex,
                        ),
                      ),],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTileCard(
                    leading: Image.asset('assets/icons/light-bulb.png', width: 32, height: 32,),
                    title: const Text('??????????????????'),
                    // expandedColor: HexColor.fromHex(MyColors.backgroundColor),
                    baseColor: Colors.white,
                    expandedTextColor: Colors.black,
                    children: <Widget>[
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 130,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: TeXView(
                              renderingEngine: renderingEngine,
                              loadingWidgetBuilder: (ctxt) => const Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              ),
                              style: TeXViewStyle(
                              ),
                              child: TeXViewColumn(children: hints),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Container(
                          height: 300,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          margin: EdgeInsets.only(left: 4, right: 4),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            child: TeXView(
                              renderingEngine: renderingEngine,
                              loadingWidgetBuilder: (ctxt) => const Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              ),
                              style: TeXViewStyle(
                                backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
                              ),
                              child: TeXViewColumn(
                                children: variants,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: resultText != null,
                        child: Container(
                          child: resultText ?? const Text(''),
                        ),
                      ),
                      Visibility(
                        visible: resultText != null,
                        child: MyCard(
                          height: 40,
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                          child: Positioned.fill(
                            child: Container(
                              color: HexColor.fromHex(MyColors.secondaryBackgroundColor),
                              child: Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  '??????????',
                                  style: TextStyle(
                                    color: HexColor.fromHex(MyColors.mainColor),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              guessedNumber += lastGuessWin ? 1 : 0;
                              addProgressComponent(context, 16, lastGuessWin);
                            });
                            if (curStep == 10) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WinScreen(
                                      score: guessedNumber,
                                    )
                                ),
                                (a) => a.isFirst,
                              );
                            } else {
                              doNextStep();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
