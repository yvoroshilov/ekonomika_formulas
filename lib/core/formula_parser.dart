import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mustache_template/mustache.dart';
import 'package:tuple/tuple.dart';

class FormulaParser {

  Future<Tuple2<List<Tuple2<String, List<Formula>>>, List<Variable>>> parse() async {
    List<Tuple2<String, List<Formula>>> formulas = [];
    List<Variable> allVars = [];
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    List<String> formulasPaths = manifestMap.keys
      .where((String key) => key.contains('formulas/'))
      .toList();

    for (String formulaPath in formulasPaths) {
      final String jsonFileContent = await rootBundle.loadString(formulaPath);
      final Map<String, dynamic> jsonContent = json.decode(jsonFileContent);

      String topicName = jsonContent['topic'];
      Map<String, dynamic> globalVariablesJsonContent = jsonContent['variables'];
      final List<dynamic> curFormulasJsonContent = jsonContent['formulas'];

      Map<String, Variable> globalVariables = {};
      for (MapEntry<String, dynamic> entry in globalVariablesJsonContent.entries) {
        Map<String, dynamic> jsonVariableContent = entry.value;
        globalVariables[entry.key] = Variable(
          entry.key,
          jsonVariableContent['latex'],
          jsonVariableContent['description'],
        );
      }
      allVars.addAll(globalVariables.values);


      Tuple2<String, List<Formula>> topic = Tuple2(topicName, []);
      for (Map<String, dynamic> formulaJsonContent in curFormulasJsonContent) {
        String moustachedLatex = formulaJsonContent['latex'];
        String description = formulaJsonContent['description'];
        List<String> variableIds = (formulaJsonContent['varIds'] as List<dynamic>)
          .map((val) => val as String)
          .toList();

        Map<String, Variable> variables = findVariables(variableIds, globalVariables);

        topic.item2.add(Formula.raw(
          moustachedLatex,
          description,
          variables: variables,
        ));
      }
      formulas.add(topic);
    }
    return Tuple2(formulas, allVars);
  }

  Map<String, Variable> findVariables(List<String> variableIds, Map<String, Variable> globalVariables) {
    Map<String, Variable> result = {};
    for (String varId in variableIds) {
      Variable varr = globalVariables[varId]!;
      result[varId] = varr;
    }
    return result;
  }
}

class Formula {
  Formula(this.latex, this.description, this._raw, {required this.variables});
  Formula.raw(String moustachedLatex, this.description, {required this.variables}) {
    _raw = moustachedLatex;
    latex = _renderMoustache(moustachedLatex, variables);
  }

  late String latex;
  late String description;
  late String _raw;
  late Map<String, Variable> variables;

  String _renderMoustache(String template, Map<String, Variable> variables) {
    Template templ = Template(template);
    Map<String, String> values = {};
    for (MapEntry<String, Variable> varr in variables.entries) {
      values[varr.key] = varr.value.latex;
    }
    return templ.renderString(values);
  }

  Formula getWithHidden(String varId) {
    Map<String, Variable> newVars = Map.of(variables);
    newVars[varId] = Variable.hiddenVariable;
    return Formula.raw(
      _raw,
      description,
      variables: newVars,
    );
  }
}

class Variable {
  Variable(this.id, this.latex, this.description);

  static final hiddenVariable = Variable('HIDDEN', r'?', '');

  final String id;
  final String latex;
  final String description;
}