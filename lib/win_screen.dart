import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'colors.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({
    Key? key,
    required this.score,
  }) : super(key: key);

  final int score;

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> {

  Tuple2<Color, String> getWinAttributes(int score) {
    if (score == 0) {
      return const Tuple2(
        Colors.red,
        'Ноль. Как можно умудриться не угадать ни одной формулы?',
      );
    } else if (score >= 1 && score <= 3) {
      return const Tuple2(
        Colors.red,
        'Позорный результат, можно сказать, ноль. Просто трата времени и зарядки телефона впустую.',
      );
    } else if (score >= 4 && score <= 6) {
      return Tuple2(
        Colors.red,
        'Самое дурацкое количество очков, которое можно было набрать, - $score. Это вообще ничего не показывает, столько можно и вслепую натыкать, если повезёт. Так что считай, что ноль.',
      );
    } else if (score >= 7 && score <= 8) {
      return Tuple2(
        Colors.red,
        'Полный провал. Если уж получилось на $score, нельзя было лучше ответить? Это невозможно никак оценить, поэтому можно считать, что ноль, разницы никакой.',
      );
    } else if (score == 9) {
      return const Tuple2(
        Colors.red,
        'Там где одна ошибка, там и две и три и десять. Это ноль.',
      );
    } else if (score == 10) {
      return const Tuple2(
        Colors.red,
        'Столько невозможно набрать без листочка с формулами, поэтому такой результат всё равно что ноль.',
      );
    } else {
      throw Exception('aaaa');
    }
  }

  @override
  Widget build(BuildContext context) {
    Tuple2<Color, String> winAttrs = getWinAttributes(widget.score);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: HexColor.fromHex(MyColors.secondaryBackgroundColor),
        title: AutoSizeText(
          '',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Container(
            height: 300,
            width: 300,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
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
              children: [
                Text(
                  'Поздравляем! Ваш результат: ',
                  style: TextStyle(
                    color: winAttrs.item1,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Text(
                  '${widget.score}/10',
                  style: TextStyle(
                    color: winAttrs.item1,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  winAttrs.item2,
                  style: TextStyle(
                    color: winAttrs.item1,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),],
        ),
      ),
    );
  }
}
