
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ekonomika/core/random_formula.dart';
import 'package:ekonomika/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
  late List<TeXViewWidget> variants = [];

  int curStep = 0;
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

    randomFormula = randForm.getRandomFormula(allFormulas, []);

    Tuple2<String, Formula> hiddenResult = randForm.hideVar(randomFormula);
    hiddenVar = randomFormula.variables[hiddenResult.item1]!;
    hiddenFormula = hiddenResult.item2;

    vars = randForm.getRandomVariables(4, allVars, [hiddenVar]);
    vars.add(hiddenVar);
    // vars.shuffle();

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

  @override
  void initState() {
    super.initState();
    resultText = null;
    guessedNumber += lastGuessWin ? 1 : 0;
    lastGuessWin = false;
    generate(mainData);
    getVariants(5);
  }

  void doNextStep() {
    setState(() {
      resultText = null;
      guessedNumber += lastGuessWin ? 1 : 0;
      lastGuessWin = false;
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
        child: TeXViewDocument(
          r'$$ ' + vars[index].latex + r' $$',
          style: const TeXViewStyle(
            height: 50,
            margin: TeXViewMargin.only(top: 4, bottom: 4),
            textAlign: TeXViewTextAlign.Center,
            // backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
            backgroundColor: Colors.white,
            borderRadius: TeXViewBorderRadius.all(20),
            elevation: 5,
            border: TeXViewBorder.all(TeXViewBorderDecoration(
              borderWidth: 1,
              borderColor: Colors.black,
              borderStyle: TeXViewBorderStyle.Solid,
            )),
          ),
        ),
        onTap: (id) {
          if (resultText != null) return;
          if (id == hiddenVar.id) {
            setState(() {
              lastGuessWin = true;
              resultText = Column(
                children: [
                  const Text(
                    r'Правильно!',
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
                    r'Ошибка! Правильный ответ: ',
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
        backgroundColor: HexColor.fromHex(MyColors.secondaryBackgroundColor),
        title: Align(
          alignment: Alignment.center,
          child: AutoSizeText(
            'STEP $curStep',
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: LinearPercentIndicator(
              animation: true,
              lineHeight: 20.0,
              animationDuration: 2500,
              percent: guessedNumber / widget.max,
              center: Text('$guessedNumber/${widget.max}'),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.green,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              // duration: const Duration(milliseconds: 500),
              // transitionBuilder: (Widget child, Animation<double> animation) {
              //   return ScaleTransition(scale: animation, child: child);
              // },
              duration: Duration(seconds: 0),
              child: Column(
                key: ValueKey<int>(curStep),
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 150,
                      maxHeight: 250,
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
                          child: TeXViewDocument(hiddenFormula.latex),
                        ),],
                      ),
                    ),
                  ),
                  ExpansionTile(
                    title: Container(
                      width: double.infinity,
                      child: Text(
                        'Hints',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 130,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: TeXView(
                            renderingEngine: renderingEngine,
                            loadingWidgetBuilder: (ctxt) => const Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            ),
                            style: TeXViewStyle(
                              backgroundColor: HexColor.fromHex(MyColors.backgroundColor),
                            ),
                            child: TeXViewColumn(children: hints),
                          ),
                        ),
                      ),
                    ],
                    trailing: Icon(Icons.arrow_drop_down_circle_outlined),
                  ),
                  Spacer(flex: 10,),
                  Flexible(
                    flex: 99,
                    child: Container(
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
                    child: ElevatedButton(
                      child: const AutoSizeText('Next'),
                      onPressed: () {
                        doNextStep();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
