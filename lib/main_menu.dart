import 'package:ekonomika/colors.dart';
import 'package:ekonomika/topics.dart';
import 'package:ekonomika/util_ui.dart';
import 'package:flutter/material.dart';

import 'game.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex(MyColors.backgroundColor),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyCard(
                width: 200,
                height: 100,
                child: Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor.fromHex(MyColors.secondaryBackgroundColor),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Random',
                        style: TextStyle(
                          color: HexColor.fromHex(MyColors.mainColor),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage(
                      max: 10,
                    )),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyCard(
                width: 200,
                height: 100,
                child: Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor.fromHex(MyColors.secondaryBackgroundColor),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'By topics',
                        style: TextStyle(
                          color: HexColor.fromHex(MyColors.mainColor),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TopicsPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}