  import 'package:flutter/material.dart';

  Widget renderImage(context, image, initialText) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.shortestSide * 0.7;

    if (image != null) {
      return  SizedBox(
                width: imageSize,
                height: imageSize,
                child:Image.memory(
                  image,
                  width: double.infinity,
                )
              );
    } else {
      return initialText;
    }
  }