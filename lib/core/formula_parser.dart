import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mustache_template/mustache.dart';
import 'package:tuple/tuple.dart';

class FormulaParser {

  Future<List<Tuple2<String, List<Formula>>>> parse() async {
    List<Tuple2<String, List<Formula>>> formulas = [];
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


      Tuple2<String, List<Formula>> topic = Tuple2(topicName, []);
      for (Map<String, dynamic> formulaJsonContent in curFormulasJsonContent) {
        String name = formulaJsonContent['name'];
        String moustachedLatex = formulaJsonContent['latex'];
        String description = formulaJsonContent['description'];
        List<String> variableIds = (formulaJsonContent['varIds'] as List<dynamic>)
          .map((val) => val as String)
          .toList();

        Map<String, Variable> variables = findVariables(variableIds, globalVariables);
        String latex = renderMoustache(moustachedLatex, variables);

        topic.item2.add(Formula(
          latex,
          description,
          variables: variables,
        ));
      }
      formulas.add(topic);
    }
    return formulas;
  }

  String renderMoustache(String template, Map<String, Variable> variables) {
    Template templ = Template(template);
    Map<String, String> values = {};
    for (MapEntry<String, Variable> varr in variables.entries) {
      values[varr.key] = varr.value.latex;
    }
    return templ.renderString(values);
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
  Formula(this.latex, this.description, {required this.variables});
  final String latex;
  final String description;
  final Map<String, Variable> variables;
}

class Variable {
  Variable(this.id, this.latex, this.description);

  final String id;
  final String latex;
  final String description;
}