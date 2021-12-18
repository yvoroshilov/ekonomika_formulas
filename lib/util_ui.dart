import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  const MyCard({
    Key? key,
    required this.width,
    required this.height,
    this.decoration,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final double width;
  final double height;
  final Decoration? decoration;
  final Widget child;
  final void Function() onTap;
  final BorderRadius br = const BorderRadius.all(Radius.circular(10));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: br,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            child,
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: br,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}