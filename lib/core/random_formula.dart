import 'dart:math';

import 'package:tuple/tuple.dart';

import 'formula_parser.dart';

class RandomFormula {

    Formula getRandomFormula(List<Formula> formulas, List<Formula> except) {
        int ind = 0;
        List<Formula> formulasCopy = List.of(formulas);
        formulasCopy.removeWhere((formula) => except.contains(formula));
        ind = Random(DateTime.now().microsecond).nextInt(formulasCopy.length);
        return formulasCopy[ind];
    }

    List<Variable> getRandomVariables(int number, List<Variable> vars, List<Variable> except) {
        Random rand = Random(DateTime.now().microsecond);
        List<Variable> varsCopy = List.of(vars);
        varsCopy.removeWhere((varr) => except.contains(varr));

        List<Variable> result = [];
        for (int i = 0; i < number; i++) {
            int ind = 0;
            ind = rand.nextInt(varsCopy.length);
            result.add(varsCopy[ind]);
            varsCopy.removeAt(ind);
        }
        return result;
    }

    Tuple2<String, Formula> hideVar(Formula formula) {
        Random rand = Random(DateTime.now().microsecond);
        int ind = rand.nextInt(formula.variables.length);
        String varId = formula.variables.values.toList()[ind].id;
        Formula hiddenFormula = formula.getWithHidden(varId);
        return Tuple2(varId, hiddenFormula);
    }
}