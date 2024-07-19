import 'package:flutter/material.dart';

class OverlayProgressIndicator extends StatelessWidget {
  const OverlayProgressIndicator({super.key, required this.visible});

  //表示状態
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return visible
        ? Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.3),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              ],
            ),
          )
        : Container();
  }
}
