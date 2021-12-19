import 'dart:math';

import 'package:tuple/tuple.dart';

import 'formula_parser.dart';

class RandomFormula {

    Formula getRandomFormula(List<Formula> formulas, List<Formula> except) {
        int ind = 0;
        do {
            ind = Random(DateTime.now().microsecond).nextInt(formulas.length);
        } while (except.contains(formulas[ind]));
        return formulas[ind];
    }

    List<Variable> getRandomVariables(int number, List<Variable> vars, List<Variable> except) {
        Random rand = Random(DateTime.now().microsecond);
        List<Variable> result = [];
        for (int i = 0; i < number; i++) {
            int ind = 0;
            do {
                ind = rand.nextInt(vars.length);
            } while (except.contains(vars[ind]) || result.contains(vars[ind]));
            result.add(vars[ind]);
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